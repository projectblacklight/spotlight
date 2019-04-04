# frozen_string_literal: true

module Spotlight
  # Mailer for reporting problems to the application contact and/or exhibit administrator
  class ContactMailer < ActionMailer::Base
    def report_problem(contact_form)
      @contact_form = contact_form
      mail(@contact_form.headers)
    end
  end
end
