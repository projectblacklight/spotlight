module Spotlight
  class Lock < ActiveRecord::Base
    belongs_to :on, polymorphic: true
    belongs_to :by, polymorphic: true

    def stale?
      created_at < (Time.now - 12.hours)
    end
  end
end