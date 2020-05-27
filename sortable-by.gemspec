Gem::Specification.new do |s|
  s.name        = 'sortable-by'
  s.version     = '0.12.1'
  s.authors     = ['Dimitrij Denissenko']
  s.email       = ['dimitrij@blacksquaremedia.com']
  s.summary     = 'Generate white-listed sort scopes from URL parameter values'
  s.description = 'ActiveRecord plugin'
  s.homepage    = 'https://github.com/bsm/sortable-by'
  s.license     = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^spec/}) }
  s.test_files    = `git ls-files -z -- spec/*`.split("\x0")
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.5'

  s.add_dependency 'activerecord'
  s.add_dependency 'activesupport'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'sqlite3'
end
