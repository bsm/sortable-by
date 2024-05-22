Gem::Specification.new do |s|
  s.name        = 'sortable-by'
  s.version     = '0.14.3'
  s.authors     = ['Dimitrij Denissenko']
  s.email       = ['dimitrij@blacksquaremedia.com']
  s.summary     = 'Generate white-listed sort scopes from URL parameter values'
  s.description = 'ActiveRecord plugin'
  s.homepage    = 'https://github.com/bsm/sortable-by'
  s.license     = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^spec/}) }
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.7'

  s.add_dependency 'activerecord'
  s.add_dependency 'activesupport'

  s.metadata['rubygems_mfa_required'] = 'true'
end
