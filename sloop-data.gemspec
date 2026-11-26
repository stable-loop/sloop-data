# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "sloop-data"
  spec.version = "0.1.0"
  spec.summary = "Reusable data management controllers, helpers, and views for Stableloop applications"
  spec.authors = ["Stableloop"]
  spec.required_ruby_version = ">= 3.2"
  spec.files = Dir.chdir(__dir__) { Dir["app/**/*", "lib/**/*"].select { |path| File.file?(path) } }
  spec.require_paths = ["lib"]
  spec.add_dependency "railties", ">= 8.0"
end
