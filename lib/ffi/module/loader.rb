# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

require 'ffi'

module FFI
	module Module
		module Loader
			def ffi_find_library_path(libname, search_paths)
				search_paths.each do |search_path|
					full_path = File.join(search_path, libname)
					if File.exist?(full_path)
						return full_path
					end
				end
				
				return nil
			end
			
			def ffi_load(name, search_paths: nil, **options)
				# Try to load the library directly:
				return true if ffi_open_library(name, **options)
				
				# If that fails, try to load it from the specified search paths:
				if search_paths&.any?
					name = FFI.map_library_name(name)
					
					if path = ffi_find_library_path(name, search_paths)
						return true if ffi_open_library(path, **options)
					end
				end
				
				return nil
			end
			
			def ffi_load_failure(message)
				raise LoadError, message
			end
		end
	end
end
