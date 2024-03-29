# frozen_string_literal: true

module Spotlight
  ##
  # Confirm new devise users
  class ConfirmationMailer < ActionMailer::Base
    include Devise::Mailers::Helpers

    def confirmation_instructions(record, token, opts, exhibit: nil)
      @token = token
      @exhibit = exhibit
      initialize_from_record(record)
      mail headers_for(:confirmation_instructions, opts)
    end
  end
end
