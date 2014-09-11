lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'production_to_seeds/version'

Gem::Specification.new do |spec|
  spec.name          = 'production_to_seeds'
  spec.version       = ProductionToSeeds::VERSION
  spec.authors       = ['Dalton Pinto']
  spec.email         = ['dalthon@aluno.ita.br']
  spec.summary       = %q{Seeds generator}
  spec.description   = %q{This gems generates seeds based on production data}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = Dir['{bin,lib,test,spec}/**/*'] + ['production_to_seeds.gemspec', 'LICENSE.txt', 'Rakefile', 'Gemfile', 'README.mdown']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }

  spec.require_paths = ['lib']

  spec.add_dependency 'archive'
  spec.add_dependency 'activerecord-import'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'bundler'
end
