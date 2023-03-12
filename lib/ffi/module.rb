# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

require_relative 'module/version'
require_relative 'module/library'
require_relative 'module/loader'

module FFI
	module Module
		def self.included(target)
			target.extend(Library)
			target.extend(Loader)
		end
	end
end
