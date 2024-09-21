# frozen_string_literal: true

require 'spotlight/version'
require 'spotlight/engine'

##
# Spotlight
module Spotlight
  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new('5.0', 'blacklight-spotlight')
  end
end
