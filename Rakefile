require 'bundler/setup'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require "bundler/gem_tasks"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ['-l'] # run lint cops only
end

require 'engine_cart/rake_task'
EngineCart.fingerprint_proc = EngineCart.rails_fingerprint_proc

task ci: ['engine_cart:generate'] do
  require 'solr_wrapper'
  ENV['environment'] = 'test'

  SolrWrapper.wrap(port: '8983') do |solr|
    solr.with_collection(name: 'blacklight-core', dir: File.join(File.expand_path(File.dirname(__FILE__)), 'solr', 'conf')) do
      # run the tests
      Rake::Task['spec'].invoke
    end
  end
end

task default: [:ci, :rubocop]

desc 'Run generated test Rails app with generated Solr instance running'
task :server do
  Rake::Task['engine_cart:generate'].invoke
  require 'solr_wrapper'

  SolrWrapper.wrap(port: '8983') do |solr|
    solr.with_collection(name: 'blacklight-core', dir: File.join(File.expand_path(File.dirname(__FILE__)), 'solr', 'conf')) do
      within_test_app do
        system 'bundle exec rails s'
      end
    end
  end
end

require 'yard'
require 'yard/rake/yardoc_task'
begin
  project_root = File.expand_path(File.dirname(__FILE__))
  doc_dest_dir = File.join(project_root, 'doc')

  YARD::Rake::YardocTask.new(:doc) do |yt|
    yt.files = Dir.glob(File.join(project_root, 'lib', '**', '*.rb')) +
               [File.join(project_root, 'README.md')]
    yt.options = ['--output-dir', doc_dest_dir, '--readme', 'README.md', '--title', 'Spotlight IIIF Resource Harvester Documentation']
  end
rescue LoadError
  desc "Generate YARD Documentation"
  task :doc do
    abort "Please install the YARD gem to generate rdoc."
  end
end