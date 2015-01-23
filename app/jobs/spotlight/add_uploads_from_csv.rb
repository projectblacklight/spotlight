module Spotlight
  class AddUploadsFromCSV < ActiveJob::Base
    queue_as :default

    after_perform do |job|
      csv_data, exhibit, user = job.arguments
      Spotlight::IndexingCompleteMailer.documents_indexed(csv_data, exhibit, user).deliver_now
    end

    def perform(csv_data, exhibit, user)
      csv_data.each do |row|
        if (url = row.delete("url")).present?
          Spotlight::Resources::Upload.create(
            remote_url_url: url,
            data: row,
            exhibit: exhibit
          )
        end
      end

    end
  end
end
