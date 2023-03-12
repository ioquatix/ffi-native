# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

begin
	require 'ffi'
rescue LoadError
	# Ignore.
	
	# The FFI gem has the following in `ffi.rb`, so we need to be careful about load order:
	# Object.send(:remove_const, :FFI) if defined?(::FFI)
end

module FFI
	module Native
		VERSION = "0.4.0"
	end
end
