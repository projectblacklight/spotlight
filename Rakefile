require "bundler/gem_tasks"
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ['-l'] # run lint cops only
end

ZIP_URL = "https://github.com/projectblacklight/blacklight-jetty/archive/v4.10.4.zip"
require 'jettywrapper'

require 'engine_cart/rake_task'
EngineCart.fingerprint_proc = EngineCart.rails_fingerprint_proc

require 'exhibits_solr_conf'

desc 'Run tests in generated test Rails app with generated Solr instance running'
task ci: ['engine_cart:generate', 'jetty:clean', 'exhibits:configure_solr'] do
  ENV['environment'] = 'test'
  jetty_params = Jettywrapper.load_config
  jetty_params[:startup_wait] = 60

  Jettywrapper.wrap(jetty_params) do
    # run the tests
    Rake::Task['spec'].invoke
  end
end

task default: [:ci, :rubocop]

require 'yard'
require 'yard/rake/yardoc_task'
begin
  project_root = File.expand_path(File.dirname(__FILE__))
  doc_dest_dir = File.join(project_root, 'doc')

  YARD::Rake::YardocTask.new(:doc) do |yt|
    yt.files = Dir.glob(File.join(project_root, 'lib', '**', '*.rb')) +
               [File.join(project_root, 'README.md')]
    yt.options = ['--output-dir', doc_dest_dir, '--readme', 'README.md', '--title', 'Stanford-Mods Documentation']
  end
rescue LoadError
  desc "Generate YARD Documentation"
  task :doc do
    abort "Please install the YARD gem to generate rdoc."
  end
end