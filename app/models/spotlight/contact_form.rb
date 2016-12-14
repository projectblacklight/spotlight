module Spotlight
  ##
  # Exhibit feedback form
  class ContactForm
    include ActiveModel::Model

    attr_accessor :current_exhibit, :name, :email, :email_address, :message, :current_url, :request

    validates :email, format: { with: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i }

    # the email_address field is intended to be hidden visually from the user, in hope that
    # a spam bot filling out the form will enter a value, whereas a human with a browser wouldn't,
    # allowing us to differentiate and reject likely spam messages.
    # the field must be present, since we expect real users to just submit the form as-is w/o
    # hacking what fields are present.
    validates :email_address, length: { is: 0 }

    def headers
      {
        to: to,
        subject: "#{I18n.t(:'blacklight.application_name')} Contact Form",
        from: %("#{name}" <#{email}>),
        cc: current_exhibit.contact_emails.join(', ')
      }
    end

    private

    def to
      Spotlight::Engine.config.default_contact_email || current_exhibit.contact_emails.first.to_s
    end
  end
end
