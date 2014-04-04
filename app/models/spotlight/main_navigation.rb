module Spotlight
  class MainNavigation < ActiveRecord::Base
    belongs_to :exhibit
    default_scope -> { order("weight ASC") }

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
