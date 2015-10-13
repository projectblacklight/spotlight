begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

ZIP_URL = 'https://github.com/projectblacklight/blacklight-jetty/archive/v4.10.4.zip'

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'Spotlight'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

require 'jettywrapper'

require 'engine_cart/rake_task'
EngineCart.fingerprint_proc = EngineCart.rails_fingerprint_proc

require 'spotlight/version'

task ci: ['engine_cart:generate', 'jetty:clean', 'spotlight:configure_jetty'] do
  ENV['environment'] = 'test'
  jetty_params = Jettywrapper.load_config
  jetty_params[:startup_wait] = 60

  Jettywrapper.wrap(jetty_params) do
    Rake::Task['spotlight:fixtures'].invoke

    # run the tests
    Rake::Task['spec'].invoke
  end
end

namespace :spotlight do
  desc 'Copies the default SOLR config for the bundled Testing Server'
  task :configure_jetty do
    FileList['solr_conf/conf/*'].each do |f|
      cp("#{f}", 'jetty/solr/blacklight-core/conf/', verbose: true)
    end
  end

  desc 'Load fixtures'
  task fixtures: ['engine_cart:generate'] do
    within_test_app do
      system 'rake spotlight_test:solr:seed RAILS_ENV=test'
      abort 'Error running fixtures' unless $?.success?
    end
  end

  desc 'Start the test application for Spotlight'
  task :server do
    Rake::Task['engine_cart:generate'].invoke

    unless File.exist? 'jetty'
      Rake::Task['jetty:clean'].invoke
      Rake::Task['spotlight:configure_jetty'].invoke
    end

    jetty_params = Jettywrapper.load_config
    jetty_params[:startup_wait] = 60

    Jettywrapper.wrap(jetty_params) do
      within_test_app do
        unless File.exist? '.initialized'
          system 'bundle exec rake spotlight:initialize'
          system 'bundle exec rake spotlight_test:solr:seed'
          File.open('.initialized', 'w') {}
        end
        system 'bundle exec rails s'
      end
    end
  end

  namespace :template do
    desc 'Start a brand new Spotlight application using the Rails template'
    task :server do
      require 'tmpdir'
      require 'fileutils'
      template_path = File.expand_path(File.join(File.dirname(__FILE__), 'template.rb'))

      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          Bundler.with_clean_env do
            version = "_#{Gem.loaded_specs['rails'].version}_" if Gem.loaded_specs['rails']

            Bundler.with_clean_env do
              IO.popen({ 'SPOTLIGHT_GEM' => File.dirname(__FILE__) },
                       ['rails', version, 'new', 'internal', '--skip-spring', '-m', template_path] +
                          [err: [:child, :out]]) do |io|
                IO.copy_stream(io, $stderr)

                _, exit_status = Process.wait2(io.pid)

                fail 'Failed to generate spotlight' if exit_status != 0
              end
            end

            Bundler.with_clean_env do
              Dir.chdir('internal') do
                APP_ROOT = Dir.pwd
                jetty_params = Jettywrapper.load_config
                Jettywrapper.wrap(jetty_params) do
                  system 'bundle exec rails s'
                end
              end
            end
          end
        end
      end
    end
  end
end

task default: [:ci, :rubocop]
