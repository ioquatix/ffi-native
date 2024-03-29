# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

require 'ffi/native'

describe FFI::Native do
	it "has a version number" do
		expect(FFI::Native::VERSION).to be =~ /\d+\.\d+\.\d+/
	end
	
	describe '#ffi_attach_function' do
		it 'can attach functions' do
			m = Module.new
			m.include(FFI::Native)
			m.ffi_open_library
			
			m.ffi_attach_function(:malloc, [:size_t], :pointer)
			m.ffi_attach_function(:free, [:pointer])
			
			pointer = m.malloc(128)
			expect(pointer).to be_a(FFI::Pointer)
			m.free(pointer)
		end
	end
end
