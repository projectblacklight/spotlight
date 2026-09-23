# frozen_string_literal: true

module Spotlight
  ##
  # Process a CSV upload into new Spotlight::Resource::Upload objects
  class AddUploadsFromCsv < Spotlight::ApplicationJob
    include Spotlight::JobTracking

    with_job_tracking(resource: ->(job) { job.arguments[1] })

    attr_reader :count, :errors

    after_perform do |job|
      csv_data, exhibit, user = job.arguments
      Spotlight::IndexingCompleteMailer.documents_indexed(
        csv_data,
        exhibit,
        user,
        indexed_count: job.count,
        errors: job.errors
      ).deliver_now
    end

    def perform(csv_data, exhibit, _user)
      @count = 0
      @errors = {}

      resources(csv_data, exhibit).each_with_index do |resource, index|
        if resource.save_and_index
          @count += 1
        else
          @errors[index + 1] = resource.errors.full_messages + resource.upload&.errors&.full_messages
        end
      end
    end

    private

    def resources(csv_data, exhibit)
      return to_enum(:resources, csv_data, exhibit) unless block_given?

      processed_csv(csv_data).each do |row|
        # Remove the URL from the row and skip if it's blank
        url = row.delete('url')
        next if url.blank?

        # Create a new resource for each row of data, and build the upload if the URL is not '~'
        resource = Spotlight::Resources::Upload.new(data: row, exhibit: exhibit)
        resource.build_upload(remote_image_url: url) unless url == '~'

        yield resource
      end
    end

    def processed_csv(csv)
      csv.map do |row|
        row.map do |label, column|
          next if column.blank?

          [label, processed_value(column)]
        end.compact.to_h
      end.compact
    end

    def processed_value(value)
      # Encode the value to UTF-8
      encoded_value = value.encode('UTF-8', invalid: :replace, undef: :replace, replace: "\uFFFD")
      return encoded_value unless encoded_value.include?('|')

      # Splits pipe-delimited values
      encoded_value.split('|').map(&:strip).compact_blank
    end
  end
end
