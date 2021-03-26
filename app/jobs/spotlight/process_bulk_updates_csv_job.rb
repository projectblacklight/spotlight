# frozen_string_literal: true

require 'csv'

module Spotlight
  ###
  class ProcessBulkUpdatesCsvJob < Spotlight::ApplicationJob
    include Spotlight::JobTracking
    with_job_tracking(resource: ->(job) { job.arguments.first })

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def perform(exhibit, bulk_update)
      errors = 0
      header_converter = ->(header) { header } # Use raw header for columns (since they are configured)
      csv_path = bulk_update.file.current_path
      File.open(csv_path) do |f|
        progress&.total = f.each_line.count(&:present?) - 1 # ignore the header

        ::CSV.table(f, header_converters: header_converter).each do |row|
          process_row(exhibit, row)
          progress&.increment
        rescue StandardError => e
          job_tracker.append_log_entry(type: :error, exhibit: exhibit, message: e.to_s)
          errors += 1
          mark_job_as_failed!
        end

        exhibit.blacklight_config.repository.connection.commit
        job_tracker.append_log_entry(type: :info, exhibit: exhibit, message: "#{progress&.progress} of #{progress&.total} (#{errors} errors)")
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    private

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    def process_row(exhibit, row)
      document = exhibit.blacklight_config.document_model.find(row[config.csv_id])
      sidecar = document.sidecar(exhibit)

      raise 'Unable to locate document' if document.blank?

      needs_reindex = false

      begin
        if sidecar.public != to_bool(row[config.csv_visibility])
          sidecar.update(public: to_bool(row[config.csv_visibility]))
          needs_reindex = true
        end

        tag_cols = row.headers.select { |k| k =~ /^#{config.csv_tags_prefix}/ }

        if tag_cols.any?
          all_tags = sidecar.all_tags_list

          added_tags_cols, removed_tags_cols = tag_cols.partition do |k|
            to_bool(row[k])
          end

          existing_or_added_tags = added_tags_cols.map { |x| x.sub(/#{config.csv_tags_prefix}\s/, '') }
          removed_tags = removed_tags_cols.map { |x| x.sub(/#{config.csv_tags_prefix}\s/, '') }

          if all_tags.difference(existing_or_added_tags).any? || existing_or_added_tags.difference(all_tags).any?
            exhibit.tag(sidecar, with: all_tags - removed_tags + existing_or_added_tags, on: :tags)
            needs_reindex = true
          end
        end
      ensure
        document.reindex(update_params: {}) if needs_reindex
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

    def to_bool(value)
      ActiveModel::Type::Boolean.new.cast(value.to_s.strip)
    end

    def config
      Spotlight::Engine.config.bulk_updates
    end
  end
end
