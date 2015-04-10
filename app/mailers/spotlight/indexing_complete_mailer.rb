module Spotlight
  ##
  # Notify the curator that we're finished processing a
  # batch upload
  class IndexingCompleteMailer < ActionMailer::Base
    def documents_indexed(csv_data, exhibit, user)
      @number = csv_data.length
      @exhibit = exhibit
      mail(to: user.email, subject: 'Document indexing complete')
    end
  end
end
