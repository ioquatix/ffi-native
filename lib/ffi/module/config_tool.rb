# frozen_string_literal: true

# Copyright, 2021, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'shellwords'

require_relative 'loader'

module FFI
	module Module
		module ConfigTool
			extend Loader
			
			def ffi_load_using_config_tool(command, search_paths: [], names: [], **options)
				return false unless output = ::IO.popen(command).read
				
				arguments = ::Shellwords.split(output)
				
				arguments.each do |argument|
					if match = argument.match(/\A(-[lL])(.*)\z/)
						command, value = match.captures
						case command
						when '-L'
							search_paths << value
						when '-l'
							names << value
						end
					else
						# Assume it's a search path:
						search_paths << value
					end
				end
				
				# Load all specified libraries:
				names.each do |name|
					ffi_load(name, search_paths: search_paths, **options)
				end
			end
		end
	end
end
