begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

ZIP_URL = "https://github.com/projectblacklight/blacklight-jetty/archive/v4.10.2.zip"

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Spotlight'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'jettywrapper'

require 'engine_cart/rake_task'
task :ci => ['engine_cart:generate', 'jetty:clean', 'spotlight:configure_jetty'] do
  ENV['environment'] = "test"
  jetty_params = Jettywrapper.load_config
  jetty_params[:startup_wait]= 60

  Jettywrapper.wrap(jetty_params) do
    Rake::Task["spotlight:fixtures"].invoke

    # run the tests
    Rake::Task["spec"].invoke
  end
end


namespace :spotlight do
  desc "Copies the default SOLR config for the bundled Testing Server"
  task :configure_jetty do
    FileList['solr_conf/conf/*'].each do |f|  
      cp("#{f}", 'jetty/solr/blacklight-core/conf/', :verbose => true)
    end
  end

  desc "Load fixtures"
  task :fixtures => ['engine_cart:generate'] do
    within_test_app do
      system "rake spotlight_test:solr:seed RAILS_ENV=test"
      abort "Error running fixtures" unless $?.success?
    end
  end

  task :server do
    if File.exists? 'spec/internal'
      within_test_app do
        system "bundle update"
      end
    else
      Rake::Task['engine_cart:generate'].invoke
    end

    unless File.exists? 'jetty'
      Rake::Task['jetty:clean'].invoke
      Rake::Task['spotlight:configure_jetty'].invoke
    end

    jetty_params = Jettywrapper.load_config
    jetty_params[:startup_wait]= 60

    Jettywrapper.wrap(jetty_params) do
      within_test_app do
        unless File.exists? '.initialized'
          system "bundle exec rake spotlight:initialize"
          system "bundle exec rake spotlight_test:solr:seed"
          File.open('.initialized', "w") {}
        end
        system "bundle exec rails s"
      end
    end
  end
end

task default: :ci
