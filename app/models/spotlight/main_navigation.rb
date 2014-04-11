module Spotlight
  class MainNavigation < ActiveRecord::Base
    belongs_to :exhibit, touch: true
    default_scope  -> { order("weight ASC") }
    scope :browse, -> { where(nav_type: "browse").take }
    scope :about,  -> { where(nav_type: "about").take  }

    def label_or_default
      if label.present?
        label
      else
        default_label
      end
    end

    def default_label
      I18n.t(:"spotlight.main_navigation.#{nav_type}")
    end
  end
end
