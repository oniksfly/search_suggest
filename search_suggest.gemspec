$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'search_suggest/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'search_suggest'
  s.version     = SearchSuggest::VERSION
  s.authors     = ['Ilya Krigouzov']
  s.email       = ['oniksfly@gmail.com']
  s.homepage    = 'https://github.com/oniksfly/onx-search-suggest'
  s.summary     = 'Grab search engine request autocomplete.'
  s.description = 'Get list of search suggests'
  s.license     = 'Private'

  s.files       = `git ls-files`.split("\n")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'rails', '~> 4.2'
  s.add_dependency 'slim'
  s.add_dependency 'sass-rails'
  s.add_dependency 'websocket-rails'
  s.add_dependency 'coffee-rails'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'compass-rails'
  s.add_dependency 'jquery-ui-rails'

  s.add_development_dependency 'bootstrap-sass', '~> 3.3.3'
end
