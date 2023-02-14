# frozen_string_literal: true

module Spotlight
  ##
  # Page-level locking to discourage update conflicts
  class Lock < ActiveRecord::Base
    belongs_to :on, polymorphic: true
    belongs_to :by, polymorphic: true, optional: true

    def current_session!
      @current_session = true
    end

    def current_session?
      !!@current_session
    end

    def stale?
      created_at < (12.hours.ago)
    end
  end
end
