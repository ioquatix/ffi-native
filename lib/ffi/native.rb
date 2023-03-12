# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

require_relative 'native/version'
require_relative 'native/library'
require_relative 'native/loader'

module FFI
	module Native
		def self.included(target)
			target.extend(Library)
			target.extend(Loader)
		end
	end
end
