require 'rails/generators'

module Spotlight
  ##
  # spotlight:increase_paper_trail_column_size generator
  class IncreasePaperTrailColumnSize < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def add_paper_trail_column_size_increase_migration
      rake 'db:migrate' # run migrations so that the versions table is created
      copy_file(
        'migrations/20180814221815_change_paper_trail_versions_object_column_to_medium_text.rb',
        'db/migrate/20180814221815_change_paper_trail_versions_object_column_to_medium_text.rb'
      )
    end
  end
end
