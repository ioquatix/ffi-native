# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

require 'ffi'

module FFI
	module Native
		module Library
			def self.extended(target)
				raise "Must only be extended by module, got #{target}!" unless target.kind_of?(Module)
				
				target.instance_variable_set(:@ffi_libraries, Array.new)
				target.instance_variable_set(:@ffi_calling_convention, :default)
				target.instance_variable_set(:@ffi_type_map, Hash.new)
				target.instance_variable_set(:@ffi_enumerations, FFI::Enums.new)
			end
			
			DEFAULT_FLAGS = FFI::DynamicLibrary::RTLD_LAZY | FFI::DynamicLibrary::RTLD_LOCAL
			
			def ffi_open_library(name = nil, flags: DEFAULT_FLAGS)
				@ffi_libraries << DynamicLibrary.open(name, flags)
				
				return true
			rescue LoadError, RuntimeError
				# TruffleRuby raises a RuntimeError if the library can't be found.
				return nil
			end
			
			def ffi_calling_convention(value = nil)
				if value
					@ffi_calling_convention = value
				end
				
				return @ffi_calling_convention
			end
			
			def ffi_attach_function(name, argument_types, return_type = :void, as: name, **options)
				argument_types = argument_types.map{|type| self.ffi_find_type(type)}
				return_type = self.ffi_find_type(return_type)
				
				options[:convention] ||= @ffi_calling_convention
				options[:type_map] ||= @ffi_type_map
				options[:enums] ||= @ffi_enumerations
				
				invoker = nil
				
				@ffi_libraries.each do |library|
					function = nil
					
					ffi_function_names(name, argument_types).each do |function_name|
						break if function = library.find_function(function_name.to_s)
					end
					
					if function
						if argument_types.length > 0 && argument_types.last == FFI::NativeType::VARARGS
							invoker = VariadicInvoker.new(function, argument_types, return_type, options)
						else
							invoker = Function.new(return_type, argument_types, function, options)
						end
						
						break
					end
				end
				
				if invoker
					invoker.attach(self, as.to_s)
					return true
				else
					raise FFI::NotFoundError.new(name, @ffi_libraries)
				end
			end
			
			def ffi_attach_variable(name, type, as: name)
				address = @ffi_libraries.find do |library|
					begin
						library.find_variable(name)
					rescue LoadError
					end
				end
				
				if address.nil? || address.null?
					raise FFI::NotFoundError.new(name, @ffi_libraries)
				end
				
				if type.is_a?(Class) && type < FFI::Struct
					variable = type.new(address)
					
					self.define_singleton_method(as) do
						variable
					end
				else
					container_type = Class.new(FFI::Struct)
					container_type.layout :value, self.ffi_find_type(type)
					container = container_type.new(address)
					
					self.define_singleton_method(as) do
						container[:value]
					end
					
					self.define_singleton_method(:"#{as}=") do |value|
						container[:value] = value
					end
				end
				
				return true
			end
			
			def ffi_callback(argument_types, return_type, **options)
				argument_types = argument_types.map{|type| self.ffi_find_type(type)}
				return_type = self.ffi_find_type(return_type)
				
				if argument_types.include?(FFI::Type::VARARGS)
					raise ArgumentError, "Callbacks cannot have variadic parameters!"
				end
				
				options[:convention] ||= @ffi_calling_convention
				options[:enums] ||= @ffi_enumerations
				
				if return_type == Type::STRING
					raise TypeError, "String is not allowed as return type of callbacks!"
				end
				
				return FFI::CallbackInfo.new(return_type, argument_types, options)
			end
			
			def ffi_define_callback(name, *arguments, **options)
				callback = ffi_callback(*arguments, **options)
				
				ffi_define_type(name, callback)
				
				return callback
			end
			
			def ffi_define_type(name, value)
				case value
				when FFI::Type
					@ffi_type_map[name] = value
				when FFI::DataConverter
					@ffi_type_map[name] = FFI::Type::Mapped.new(value)
				else
					@ffi_type_map[name] = self.ffi_find_type(value)
				end
			end
			
			def ffi_define_enumeration(name, *arguments)
				native_type = arguments.first.kind_of?(FFI::Type) ? arguments.shift : nil
				
				ffi_define_generic_enumeration(name, FFI::Enum, native_type, *arguments)
			end
			
			def ffi_define_bitmask(name, *arguments)
				native_type = arguments.first.kind_of?(FFI::Type) ? arguments.shift : nil
				
				ffi_define_generic_enumeration(name, FFI::Bitmask, native_type, *arguments)
			end
			
			def ffi_find_type(argument)
				if argument.kind_of?(Type)
					return argument
				end
				
				if type = @ffi_type_map[argument]
					return type
				end
				
				if argument.is_a?(Class) && argument < Struct
					return Type::POINTER
				end
				
				if argument.is_a?(DataConverter)
					# Cache the mapped type:
					return ffi_define_type(argument, Type::Mapped.new(argument))
				end
				
				if argument
					return FFI.find_type(argument)
				end
			end
			
		private
			
			def ffi_define_generic_enumeration(name, klass, native_type, values)
				enumeration = nil
				
				if native_type
					enumeration = klass.new(native_type, values, name)
				else
					enumeration = klass.new(values, name)
				end
				
				@ffi_enumerations << enumeration
				
				ffi_define_type(name, enumeration)
				
				return enumeration
			end
			
			def ffi_function_names(name, argument_types)
				result = [name]
				
				if @ffi_calling_convention == :stdcall
					# Get the size of each parameter:
					size = argument_types.inject(0) do |total, argument|
						size = argument.size
						
						# The size must be a multiple of 4:
						size += (4 - size) % 4
						
						total + size
					end
					
					# win32 naming convention:
					result << "_#{name.to_s}@#{size}"
					
					# win64 naming convention:
					result << "#{name.to_s}@#{size}"
				end
				
				return result
			end
		end
	end
end
