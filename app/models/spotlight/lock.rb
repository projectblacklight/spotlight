module Spotlight
  ##
  # Page-level locking to discourage update conflicts
  class Lock < ActiveRecord::Base
    belongs_to :on, polymorphic: true
    belongs_to :by, polymorphic: true

    def current_session!
      @current_session = true
    end

    def current_session?
      !!@current_session
    end

    def stale?
      created_at < (Time.zone.now - 12.hours)
    end
  end
end
