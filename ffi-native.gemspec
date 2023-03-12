# frozen_string_literal: true

require_relative "lib/ffi/native/version"

Gem::Specification.new do |spec|
	spec.name = "ffi-native"
	spec.version = FFI::Native::VERSION
	
	spec.summary = "Write a short summary, because RubyGems requires one."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/ioquatix/ffi-native"
	
	spec.metadata = {
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
	}
	
	spec.files = Dir.glob(['{lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 2.4.0"
	
	spec.add_dependency "ffi"
	
	spec.add_development_dependency "bake"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "sus", "~> 0.18"
end
