# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pivotal_db/version"

Gem::Specification.new do |s|
  s.name        = "pivotal_db"
  s.version     = PivotalDb::VERSION
  s.authors     = ["Fraser Newton"]
  s.email       = ["fraser@goclio.com"]
  s.homepage    = ""
  s.summary     = %q{Offline Access to Pivotal Tracker projects}
  s.description = %q{Pull a Pivotal Tracker project into an sqlite DB and provides basic search functionality through a CLI}

  s.rubyforge_project = "pivotal_db"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_dependency "pivotal-tracker", "~>0.4"
  s.add_dependency "sqlite3", "~>1.3"
  s.add_dependency "data_mapper"
  s.add_dependency "dm-sqlite-adapter"
  s.add_dependency "thor"
  s.add_dependency "configliere"
end
