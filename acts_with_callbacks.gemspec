# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "acts_with_callbacks/version"

Gem::Specification.new do |s|
  s.name        = "acts_with_callbacks"
  s.version     = ActsWithCallbacks::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Thane Vo"]
  s.email       = ["vothane@gmail.com"]
  s.homepage    = "portvolio.heroku.com"
  s.summary     = %q{Adds (before|after)_save and (before|after)_destroy callbacks to ActiveResource}
  s.description = %q{Under Development}
  
  s.add_development_dependency "active_resource", ">= 3.0.0"
  s.add_development_dependency "active_support", ">= 3.0.0"
  s.add_development_dependency "rspec", ">= 2.5.0"

  #s.rubyforge_project = "acts_with_callbacks"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
