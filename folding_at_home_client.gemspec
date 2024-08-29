# frozen_string_literal: true

require_relative 'lib/folding_at_home_client/version'

Gem::Specification.new do |spec|
  spec.name = 'folding_at_home_client'
  spec.version = FoldingAtHomeClient::VERSION

  spec.authors = ['Blake Gearin']
  spec.email = 'hello@blakeg.me'

  spec.summary = 'Ruby client for Folding@Home'
  spec.description = 'Ruby client for Folding@Home'
  spec.homepage = 'https://github.com/blakegearin/folding_at_home_client'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/blakegearin/folding_at_home_client'
  spec.metadata['github_repo'] = 'ssh://github.com/blakegearin/folding_at_home_client'

  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 2.9'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
