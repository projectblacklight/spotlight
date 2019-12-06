# frozen_string_literal: true

module Spotlight
  # Extension point for downstream applications to override to
  # check if a delayed job still needs to run
  class ValidityChecker
    # Return a validity token
    # @param [ActiveModel::Model]
    # @return [Object] any serializable object
    def mint(_model); end

    # Check if the token is still valid for the model
    # @param [ActiveModel::Model]
    # @param [Object] the serializable token minted by #mint
    # @return [boolean]
    def check(_model, _token)
      true
    end
  end
end
