module Spotlight
  class ContactEmail < ActiveRecord::Base
    extend Devise::Models
    devise :confirmable
    belongs_to :exhibit
    validate :valid_email
    validates :exhibit, presence: true

    def to_s
      email
    end

    def recently_sent?
      confirmation_sent_at > 3.days.ago if confirmation_sent_at?
    end

    protected 

    def valid_email
      begin
        parsed = Mail::Address.new(email)
      rescue Mail::Field::ParseError => e
      end
      errors.add :email, "is not valid" unless !parsed.nil? && parsed.address == email && parsed.local != email #cannot be a local address
    end

    def send_devise_notification(notification, *args)
      notification_mailer.send(notification, self, *args).deliver
    end

    def notification_mailer
      Spotlight::ConfirmationMailer
    end

  end
end



