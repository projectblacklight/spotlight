# frozen_string_literal: true

module Spotlight
  ##
  # Notify the curator that we're finished processing a
  # batch upload
  class IndexingCompleteMailer < ActionMailer::Base
    def documents_indexed(csv_data, exhibit, user, indexed_count, errors)
      @number = indexed_count || csv_data.length
      @exhibit = exhibit
      @errors = errors || []
      mail(to: user.email, subject: 'Document indexing complete')
    end
  end
end
