# frozen_string_literal: true

module Spotlight
  ##
  # Exhibit saved searches
  class Group < ActiveRecord::Base
    include Spotlight::Translatables

    extend FriendlyId

    friendly_id :title, use: %i[slugged scoped finders history], scope: [:exhibit]
    translates :title

    self.table_name = 'spotlight_groups'
    belongs_to :exhibit
    has_many :group_members
    has_many :searches, through: :group_members, source: :member, source_type: 'Spotlight::Search'
    default_scope { order(:weight) }
    scope :published, -> { where(published: true) }
    accepts_nested_attributes_for :group_members
    accepts_nested_attributes_for :searches
  end
end
