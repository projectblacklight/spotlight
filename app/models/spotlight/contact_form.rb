require 'mail_form'

module Spotlight
  ##
  # Exhibit feedback form
  class ContactForm < MailForm::Base
    attribute :current_exhibit
    attribute :name, validate: false
    attribute :email, validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
    attribute :message
    attribute :current_url

    append :remote_ip, :user_agent

    def headers
      {
        subject: "#{I18n.t(:'blacklight.application_name')} Contact Form",
        to: current_exhibit.contact_emails.first,
        from: %("#{name}" <#{email}>),
        cc: current_exhibit.contact_emails.join(', ')
      }
    end
  end
end
