module Spotlight
  ##
  # After renaming an exhibit-specific field, we also
  # need to update the sidecars that may contain that field
  class RenameSidecarFieldJob < ActiveJob::Base
    queue_as :default

    def perform(exhibit, old_field, new_field)
      exhibit.solr_document_sidecars.find_each do |s|
        if s.data[old_field]
          s.data_will_change!
          s.data[new_field] = s.data.delete(old_field)
          s.save
          s.document.reindex
        end
      end
    end
  end
end
