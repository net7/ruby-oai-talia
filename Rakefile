RUBY_OAI_VERSION = '0.0.12'

require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'

task :default => ["test"]

task :test => ["test:client", "test:provider"]

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "oai_talia"
    s.summary = "A ruby library for working with the Open Archive Initiative Protocol for Metadata Harvesting (OAI-PMH)"
    s.email = "ghub@limitedcreativity.org"
    s.homepage = "http://trac.talia.discovery-project.eu/"
    s.description = "A ruby library for working with the Open Archive Initiative Protocol for Metadata Harvesting (OAI-PMH). Fork of the original version by Ed Summers, aims for best standards compatibility (test with http://re.cs.uct.ac.za/)"
    s.required_ruby_version = '>= 1.8.6'
    s.authors = ["Ed Summers", "Daniel Hahn"]
    s.homepage = 'http://github.com/net7/ruby-oai-talia/'
    s.platform = Gem::Platform::RUBY
    s.require_path = 'lib'
    s.autorequire = 'oai'
    s.has_rdoc = true
    s.bindir = 'bin'
    s.executables = 'oai'

    s.add_dependency('builder', '>=2.0.0')
    
    s.files = %w(README Rakefile) +
      Dir.glob("{bin,test,lib}/**/*") + 
      Dir.glob("examples/**/*.rb")
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

namespace :test do
  Rake::TestTask.new('client') do |t|
    t.libs << ['lib', 'test/client']
    t.pattern = 'test/client/tc_*.rb'
    t.verbose = true
  end

  Rake::TestTask.new('provider') do |t|
    t.libs << ['lib', 'test/provider']
    t.pattern = 'test/provider/tc_*.rb'
    t.verbose = true
  end

  desc "Active Record base Provider Tests"
  Rake::TestTask.new('activerecord_provider') do |t|
    t.libs << ['lib', 'test/activerecord_provider']
    t.pattern = 'test/activerecord_provider/tc_*.rb'
    t.verbose = true
  end

  desc 'Measures test coverage'
  # borrowed from here: http://clarkware.com/cgi/blosxom/2007/01/05#RcovRakeTask
  task :coverage do
    rm_f "coverage"
    rm_f "coverage.data"
    system("rcov --aggregate coverage.data --text-summary -Ilib:test/provider test/provider/tc_*.rb")
    system("rcov --aggregate coverage.data --text-summary -Ilib:test/client test/client/tc_*.rb")
    system("open coverage/index.html") if PLATFORM['darwin']
  end

end

task 'test:activerecord_provider' => :create_database

task :environment do 
  unless defined? OAI_PATH
    OAI_PATH = File.dirname(__FILE__) + '/lib/oai'
    $LOAD_PATH << OAI_PATH
    $LOAD_PATH << File.dirname(__FILE__) + '/test'
  end
end

task :drop_database => :environment do
  %w{rubygems active_record yaml}.each { |lib| require lib }
  require 'activerecord_provider/database/ar_migration'
  require 'activerecord_provider/config/connection'
  begin
    OAIPMHTables.down
  rescue
  end
end

task :create_database => :drop_database do
  OAIPMHTables.up
end

task :load_fixtures => :create_database do
  require 'test/activerecord_provider/models/dc_field'
  fixtures = YAML.load_file(
    File.join('test', 'activerecord_provider', 'fixtures', 'dc.yml')
  )
  fixtures.keys.sort.each do |key|
    DCField.create(fixtures[key])
  end
end
  
Rake::RDocTask.new('doc') do |rd|
  rd.rdoc_files.include("lib/**/*.rb", "README")
  rd.main = 'README'
  rd.rdoc_dir = 'doc'
end

begin
  require 'gokdok'
  Gokdok::Dokker.new do |gd|
    gd.remote_path = ''
    gd.rdoc_task = :doc
    gd.doc_home = 'doc'
  end
rescue LoadError
  puts "Gokdoc not available. Install it with: gem install gokdok"
end
