
require_relative "lib/ffi/module/version"

Gem::Specification.new do |spec|
	spec.name = "ffi-module"
	spec.version = FFI::Module::VERSION
	
	spec.summary = "Write a short summary, because RubyGems requires one."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.homepage = "https://github.com/ioquatix/ffi-module"
	
	spec.metadata = {
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
	}
	
	spec.files = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 2.4.0"
	
	spec.add_dependency "ffi"
end
