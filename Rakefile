# frozen_string_literal: true

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'Spotlight'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks

require 'solr_wrapper'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

require 'engine_cart/rake_task'

require 'spotlight/version'

# Build with our opinionated defaults if none are provided.
rails_options = ENV.fetch('ENGINE_CART_RAILS_OPTIONS', '')
rails_options = "#{rails_options} -a propshaft" unless rails_options.match?(/-a\s|--asset-pipeline/)
rails_options = "#{rails_options} -j importmap" unless rails_options.match?(/-j\s|--javascript/)
rails_options = "#{rails_options} --css bootstrap" unless rails_options.match?(/--css/)
ENV['ENGINE_CART_RAILS_OPTIONS'] = rails_options

task ci: ['engine_cart:generate'] do
  ENV['environment'] = 'test'

  SolrWrapper.wrap(port: '8983') do |solr|
    solr.with_collection(name: 'blacklight-core', dir: 'lib/generators/spotlight/templates/solr/conf') do
      Rake::Task['spotlight:fixtures'].invoke
      within_test_app do
        system 'bin/rake spec:prepare'
      end

      # run the tests
      Rake::Task['spec'].invoke
    end
  end
end

namespace :spotlight do
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

    SolrWrapper.wrap(port: '8983') do |solr|
      solr.with_collection(name: 'blacklight-core', dir: 'lib/generators/spotlight/templates/solr/conf') do
        within_test_app do
          unless File.exist? '.initialized'
            system 'bin/rails spotlight:initialize spotlight_test:solr:seed'
            File.open('.initialized', 'w') {}
          end
          system 'bin/dev'
        end
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
          Bundler.with_unbundled_env do
            version = "_#{Gem.loaded_specs['rails'].version}_" if Gem.loaded_specs['rails']

            Bundler.with_unbundled_env do
              IO.popen({ 'SPOTLIGHT_GEM' => File.dirname(__FILE__) },
                       ['rails', version, 'new', 'internal', '--skip-spring', '-m', template_path] +
                          [err: %i[child out]]) do |io|
                IO.copy_stream(io, $stderr)

                _, exit_status = Process.wait2(io.pid)

                raise 'Failed to generate spotlight' if exit_status.nonzero?
              end
            end

            Bundler.with_unbundled_env do
              Dir.chdir('internal') do
                APP_ROOT = Dir.pwd
                SolrWrapper.wrap(port: '8983') do |solr|
                  solr.with_collection(name: 'blacklight-core', dir: File.join(File.expand_path('..', File.dirname(__FILE__)), 'solr', 'conf')) do
                    system 'bin/rails s'
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

task default: %i[rubocop ci]
