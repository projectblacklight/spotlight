# frozen_string_literal: true

module Spotlight
  ##
  # After renaming an exhibit-specific field, we also
  # need to update the sidecars that may contain that field
  class RenameSidecarFieldJob < Spotlight::ApplicationJob
    include Spotlight::JobTracking
    with_job_tracking(resource: ->(job) { job.arguments.first })

    def perform(exhibit, old_field, new_field, old_slug = nil, new_slug = nil)
      exhibit.solr_document_sidecars.find_each do |s|
        # this data migration should be relatively rare
        migrate_data!(s, old_slug, new_slug)
        migrate_data!(s, old_field, new_slug || new_field) # for backwards compatibility

        # more likely, the indexing rules changed and we have to reindex
        reindex_document!(s) if old_field != new_field && s.data[new_slug || new_field]
      end
    end

    private

    def migrate_data!(sidecar, old_field, new_field)
      return if old_field == new_field || !sidecar.data.key?(old_field)

      sidecar.data_will_change!
      sidecar.data[new_field] = sidecar.data.delete(old_field)
      sidecar.save
    end

    def reindex_document!(sidecar)
      sidecar.document.reindex
    end
  end
end
