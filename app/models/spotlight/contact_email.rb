module Spotlight
  ##
  # Exhibit feedback contacts
  class ContactEmail < ActiveRecord::Base
    extend Devise::Models
    devise :confirmable
    belongs_to :exhibit
    validate :valid_email
    validates :exhibit, presence: true

    scope :confirmed, -> { where.not(confirmed_at: nil) }

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
        Rails.logger.debug "Failed to parse email #{email}: #{e}"
      end

      errors.add :email, 'is not valid' if parsed.nil? || parsed.address != email || parsed.local == email
    end

    def send_devise_notification(notification, *args)
      notice = notification_mailer.send(notification, self, *args)
      if notice.respond_to? :deliver_now
        notice.deliver_now
      else
        notice.deliver
      end
    end

    def notification_mailer
      Spotlight::ConfirmationMailer
    end
  end
end
