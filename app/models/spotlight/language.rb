module Spotlight
  # A language for an exhibit
  class Language < ActiveRecord::Base
    belongs_to :exhibit
    validates :locale, presence: true
  end
end
