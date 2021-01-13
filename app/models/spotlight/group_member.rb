# frozen_string_literal: true

module Spotlight
  ##
  # Exhibit saved searches
  class GroupMember < ActiveRecord::Base
    self.table_name = 'spotlight_groups_members'
    belongs_to :group
    belongs_to :member, polymorphic: true
  end
end
