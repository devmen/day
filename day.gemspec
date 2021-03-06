# encoding: UTF-8

Gem::Specification.new do |s|

  s.name = "day"
  s.version = "0.0.5"
  s.date = %q{2012-03-19}
  s.platform = Gem::Platform::RUBY
  s.authors = ["Serge Gerasimov"]
  s.email = ["mail@grsmv.com"]
  s.homepage = "http://github.com/grsmv/day"
  s.summary = "Gem for date parsing"
  s.description = "Gem for date parsing (in the scale of the day, hours is not very important in my projects now). It support Russian and Ukrainian (in future) languages."
  s.rubyforge_project = s.name
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")

  s.files  = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
end
