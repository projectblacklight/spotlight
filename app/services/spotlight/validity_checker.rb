# frozen_string_literal: true

module Spotlight
  # Extension point for downstream applications to override to
  # check if a delayed job still needs to run
  class ValidityChecker
    # Return a validity token
    # @param [ActiveJob::Base]
    # @return [Object] any serializable object
    def mint(_job); end

    # Check if the token is still valid for the model
    # @param [ActiveJob::Base]
    # @param [Object] the serializable token minted by #mint
    # @return [boolean]
    def check(_job, validity_token: nil)
      validity_token || true
    end
  end
end
