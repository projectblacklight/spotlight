module Spotlight
  class IndexingCompleteMailer < ActionMailer::Base

    def documents_indexed(csv_data, exhibit, user)
      @number = csv_data.length
      @exhibit = exhibit
      mail(to: user.email, subject: "Document indexing complete")
    end
  end
end
