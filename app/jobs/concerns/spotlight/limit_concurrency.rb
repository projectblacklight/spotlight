# frozen_string_literal: true

module Spotlight
  # Job status tracking
  module LimitConcurrency
    extend ActiveSupport::Concern

    VALIDITY_TOKEN_PARAMETER = 'validity_token'

    included do
      # The validity checker is a seam for implementations to expire unnecessary
      # indexing tasks if it becomes redundant while waiting in the job queue.
      class_attribute :validity_checker, default: Spotlight::ValidityChecker.new

      before_enqueue do |job|
        token = job.arguments.last[VALIDITY_TOKEN_PARAMETER] if job.arguments.last.is_a?(Hash)
        token ||= validity_checker.mint(job)

        job.arguments << {} unless job.arguments.last.is_a? Hash
        job.arguments.last[VALIDITY_TOKEN_PARAMETER] = token
      end

      before_perform do |job|
        next unless job.arguments.last.is_a?(Hash)

        token = job.arguments.last.delete(VALIDITY_TOKEN_PARAMETER)
        throw(:abort) unless token.nil? || validity_checker.check(job, validity_token: token)

        job.arguments.pop if job.arguments.last.empty?
      end
    end
  end
end
