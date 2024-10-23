
# frozen_string_literal: true

module Spotlight
  ##
  # General helper for checking and using ActionCable
  module ActioncableHelper
    def actioncable?
      defined?(ActionCable.server) && ActionCable.server.config.cable.present?
    end

    def ws_broadcast(channel, data)
      return unless actioncable?

      ActionCable.server.broadcast channel, data
    end
  end
end