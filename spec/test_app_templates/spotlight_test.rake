# frozen_string_literal: true

require 'rake'

namespace :spotlight_test do
  namespace :solr do
    desc 'Index test data into solr; must be run from within an app (see spotlight:fixtures)'
    task :seed do
      docs = YAML.safe_load(File.open(File.expand_path(File.join('..', 'spec', 'fixtures', 'sample_solr_documents.yml'), Rails.root)))
      Blacklight.default_index.connection.add docs
      Blacklight.default_index.connection.commit
    end
  end
end
