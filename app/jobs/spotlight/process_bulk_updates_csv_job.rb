# frozen_string_literal: true

module Spotlight
  ###
  class ProcessBulkUpdatesCsvJob < Spotlight::ApplicationJob
    include Spotlight::JobTracking

    def perform(exhibit, csv_path)
      errors = 0

      File.open(csv_path) do |f|
        progress.total = f.each_line.count

        CSV.table(f).each do |row|
          document = exhibit.blacklight_config.document_model.find(row['Item ID'])
          sidecar = document.sidecar(exhibit)

          raise 'Unable to locate document' if document.blank?

          sidecar.update(public: row['Visibility'])

          added_tags_cols, removed_tags_cols = row.keys.select { |k| k =~ /^Tag:/ }.partition do |k|
            ActiveModel::Type::Boolean.new.cast(row[k])
          end

          added_tags = added_tags_cols.map { |x| x.sub(/Tag:\s/, '') }
          removed_tags = removed_tags_cols.map { |x| x.sub(/Tag:\s/, '') }

          all_tags = sidecar.all_tags_list

          exhibit.tag(sidecar, with: all_tags - removed_tags + added_tags, on: :tags)

          document.reindex(update_params: {})

          progress.increment
        rescue StandardError => e
          job_tracker.append_log_entry(type: :error, exhibit: exhibit, message: e.to_s)
          errors += 1
          mark_job_as_failed!
        end

        exhibit.blacklight_config.repository.connection.commit
        job_tracker.append_log_entry(type: :info, exhibit: exhibit, message: "#{progress.progress} of #{progress.total} (#{errors} errors)")
      end
    end
  end
end
