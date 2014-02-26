module Spotlight
  class ContactEmail < ActiveRecord::Base
    belongs_to :exhibit
    validate :valid_email

    def to_s
      email
    end

    protected 
    def valid_email
      begin
        parsed = Mail::Address.new(email)
      rescue Mail::Field::ParseError => e
      end
      errors.add :email, "is not valid" unless !parsed.nil? && parsed.address == email && parsed.local != email #cannot be a local address
    end

  end
end
