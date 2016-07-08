module Spotlight
  ##
  # Exhibit feedback form
  class ContactForm
    include ActiveModel::Model

    attr_accessor :current_exhibit, :name, :email, :message, :current_url, :request

    validates :email, format: { with: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i }

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
