module Spotlight
  ##
  # Confirm new devise users
  class ConfirmationMailer < ActionMailer::Base
    include Devise::Mailers::Helpers

    def confirmation_instructions(record, token, opts)
      @token = token
      initialize_from_record(record)
      mail headers_for(:confirmation_instructions, opts)
    end
  end
end
