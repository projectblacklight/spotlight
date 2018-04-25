module Spotlight
  ##
  # Exhibit navbar links
  class MainNavigation < ActiveRecord::Base
    include Spotlight::Translatables

    belongs_to :exhibit, touch: true
    default_scope { order('weight ASC') }
    scope :browse, -> { find_by(nav_type: 'browse') }
    scope :about, -> { find_by(nav_type: 'about') }
    scope :curated_features, -> { find_by(nav_type: 'curated_features') }
    scope :displayable, -> { where(display: true) }
    translates :label

    def displayable?
      display?
    end

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

    private

    ##
    # Allows us to scope translations namespace.
    def slug
      ['main_navigation', nav_type].join('.')
    end
  end
end
