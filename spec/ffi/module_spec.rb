# frozen_string_literal: true

require_relative '../../lib/ffi/module'

RSpec.describe FFI::Module do
	it "has a version number" do
		expect(FFI::Module::VERSION).not_to be nil
	end
	
	describe '#ffi_attach_function' do
		it 'can attach functions' do
			m = Module.new
			m.include(FFI::Module)
			m.ffi_open_library
			
			m.ffi_attach_function(:malloc, [:size_t], :pointer)
			m.ffi_attach_function(:free, [:pointer])
			
			pointer = m.malloc(128)
			expect(pointer).to be_kind_of(FFI::Pointer)
			m.free(pointer)
		end
	end
end
