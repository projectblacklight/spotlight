# frozen_string_literal: true

module Spotlight
  ##
  # Process a CSV upload into new Spotlight::Resource::Upload objects
  class AddUploadsFromCsv < ActiveJob::Base
    queue_as :default

    after_perform do |job|
      csv_data, exhibit, user = job.arguments
      Spotlight::IndexingCompleteMailer.documents_indexed(csv_data, exhibit, user).deliver_now
    end

    def perform(csv_data, exhibit, _user)
      encoded_csv(csv_data).each do |row|
        url = row.delete('url')
        next unless url.present?

        resource = Spotlight::Resources::Upload.new(
          data: row,
          exhibit: exhibit
        )
        resource.build_upload(remote_image_url: url) unless url == '~'
        resource.save_and_index
      end
    end

    private

    def encoded_csv(csv)
      csv.map do |row|
        row.map do |label, column|
          [label, column.encode('UTF-8', invalid: :replace, undef: :replace, replace: "\uFFFD")] if column.present?
        end.compact.to_h
      end.compact
    end
  end
end
