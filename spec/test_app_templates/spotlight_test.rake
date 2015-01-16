require 'rake'

namespace :spotlight_test do
  namespace :solr do
    desc "Index test data into solr; must be run from within an app (see spotlight:fixtures)"
    task :seed do
      response = JSON.parse(File.read(File.expand_path(File.join('..', 'fixtures', 'sample_solr_docs.json'), Rails.root)))
      Blacklight.solr.add response['response']['docs'].map { |x| x.except('_version_', 'pub_date_search').reject { |k,v| k =~ /exhibit_/ or k =~ /unstem/ or k =~ /exact/ } }
      Blacklight.solr.commit
    end
  end
end