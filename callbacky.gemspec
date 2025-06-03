# frozen_string_literal: true

require_relative "lib/callbacky/version"

Gem::Specification.new do |spec|
  spec.name = "callbacky"
  spec.version = Callbacky::VERSION
  spec.authors = ["pucinsk"]
  spec.email = ["jokubas.dev@gmail.com"]

  spec.summary = "Define declarative custom before/after hooks in your application"
  spec.description = "Callbacky is a lightweight Ruby gem that allows you to define and run custom lifecycle callbacks like before and after in a clean, expressive way"
  spec.homepage = "https://github.com/pucinsk/callbacky"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile]) ||
        %w[flake.nix flake.lock].include?(f)
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
