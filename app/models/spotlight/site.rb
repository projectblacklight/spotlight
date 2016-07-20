module Spotlight
  ##
  # Global spotlight configuration
  class Site < ActiveRecord::Base
    has_many :exhibits
    has_many :roles, as: :resource
    has_many :tags, -> { distinct }, through: :exhibits

    belongs_to :masthead, dependent: :destroy

    accepts_nested_attributes_for :masthead, update_only: true
    accepts_nested_attributes_for :exhibits
    accepts_nested_attributes_for :tags, allow_destroy: true

    def self.instance
      first || create
    end

    def tag_list
      tags.map(&:name)
    end

    ##
    # Only persist tag updates; any new tags will get created when they
    # are assigned to an exhibit.
    def tags_attributes=(attributes_collection)
      super(attributes_collection.select { |x| x['id'].present? })
    end

    ##
    # Rails doesn't automatically delete deeply nested associations, so we
    # need to handle this manually.
    def autosave_associated_records_for_tags
      tags.select(&:marked_for_destruction?).each(&:delete)
      tags.each(&:save)
      tags.reload
    end
  end
end
