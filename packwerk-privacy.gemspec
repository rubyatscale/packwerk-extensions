Gem::Specification.new do |spec|
  spec.name          = 'packwerk-privacy'
  spec.version       = '0.0.1'
  spec.authors       = ['Gusto Engineers']
  spec.email         = ['dev@gusto.com']

  spec.summary       = 'A plugin to help packwerk packages enforce us of public API.'
  spec.description   = 'A plugin to help packwerk packages enforce us of public API.'
  spec.homepage      = 'https://github.com/rubyatscale/packwerk-privacy'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/rubyatscale/packwerk-privacy'
    spec.metadata['changelog_uri'] = 'https://github.com/rubyatscale/packwerk-privacy/releases'
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.0')
  # Specify which files should be added to the gem when it is released.
  spec.files = Dir['README.md', 'lib/**/*']

  spec.add_dependency 'packwerk', '>= 2.2.1'
end
