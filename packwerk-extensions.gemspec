Gem::Specification.new do |spec|
  spec.name          = 'packwerk-extensions'
  spec.version       = '0.2.0'
  spec.authors       = ['Gusto Engineers']
  spec.email         = ['dev@gusto.com']

  spec.summary       = 'A collection of extensions for packwerk packages.'
  spec.description   = 'A collection of extensions for packwerk packages.'
  spec.homepage      = 'https://github.com/rubyatscale/packwerk-extensions'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/rubyatscale/packwerk-extensions'
    spec.metadata['changelog_uri'] = 'https://github.com/rubyatscale/packwerk-extensions/releases'
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  spec.required_ruby_version = Gem::Requirement.new('>= 2.7')
  # Specify which files should be added to the gem when it is released.
  spec.files = Dir['README.md', 'lib/**/*']

  spec.add_dependency 'packwerk', '>= 2.2.1'
  spec.add_dependency 'railties', '>= 6.0.0'
  spec.add_dependency 'sorbet-runtime'
  spec.add_dependency 'zeitwerk'

  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'sorbet'
  spec.add_development_dependency 'sorbet-static'
  spec.add_development_dependency 'tapioca'
end
