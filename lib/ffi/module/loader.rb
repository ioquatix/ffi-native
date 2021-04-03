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
		end
	end
end
