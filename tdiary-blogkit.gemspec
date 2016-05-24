# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tdiary/blogkit/version'

Gem::Specification.new do |spec|
  spec.name          = "tdiary-blogkit"
  spec.version       = TDiary::Blogkit::VERSION
  spec.authors       = ["tDiary contributors"]
  spec.email         = ["support@tdiary.org"]
  spec.summary       = %q{tDiary blogkit package.}
  spec.description   = %q{tDiary BlogKit modifies tDiary. This modification enables tDiary to manage articles by topics, not daily.}
  spec.homepage      = "http://www.tdiary.org/"
  spec.license       = "GPL2"

  spec.files         = Dir[
    'ChangeLog',
    'COPYING',
    'Rakefile',
    'README.md',
    'README.en.md',
    'tdiary.conf.sample',
    'tdiary.conf.sample_ja',
    'UPDATE.md',
    'UPDATE.en.md',
    'bin/**/*',
    'js/**/*',
    'lib/**/*',
    'plugin/**/*',
    'spec/**/*'
  ]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'hikidoc'
  spec.add_dependency 'tdiary'
  spec.add_dependency 'tdiary-style-rd'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
