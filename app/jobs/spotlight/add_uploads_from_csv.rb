module Spotlight
  class AddUploadsFromCSV < ActiveJob::Base
    queue_as :default

    after_perform do |job|
      Spotlight::IndexingCompleteMailer.documents_indexed(job.arguments[0], job.arguments[1], job.arguments[2]).deliver_now
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
