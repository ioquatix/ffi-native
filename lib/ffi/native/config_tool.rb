# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

require 'shellwords'

require_relative 'loader'

module FFI
	module Native
		module ConfigTool
			extend Loader
			
			def ffi_load_using_config_tool(command, search_paths: [], names: [], **options)
				return false unless output = ::IO.popen(command).read
				
				arguments = ::Shellwords.split(output)
				search_paths = search_paths.dup
				names = names.dup
				
				arguments.each do |argument|
					if match = argument.match(/\A(-[lL])(.*)\z/)
						command, value = match.captures
						case command
						when '-L'
							search_paths << value
						when '-l'
							names << value
						end
					elsif File.directory?(argument)
						# Assume it's a search path:
						search_paths << argument
					end
				end
				
				result = false
				
				# Load all specified libraries:
				names.each do |name|
					result = ffi_load(name, search_paths: search_paths, **options) || result
				end
				
				return result
			rescue Errno::ENOENT
				return nil
			end
		end
	end
end
