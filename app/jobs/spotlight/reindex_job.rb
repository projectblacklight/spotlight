module Spotlight
  ##
  # Reindex the given resources or exhibits
  class ReindexJob < ActiveJob::Base
    queue_as :default

    before_enqueue do |job|
      resource_list(job.arguments.first).each(&:waiting!)
    end

    def perform(exhibit_or_resources)
      resource_list(exhibit_or_resources).each(&:reindex)
    end

    private

    def resource_list(exhibit_or_resources)
      case
      when exhibit_or_resources.is_a?(Spotlight::Exhibit)
        exhibit_or_resources.resources.find_each
      when exhibit_or_resources.is_a?(Enumerable)
        exhibit_or_resources
      else
        Array(exhibit_or_resources)
      end
    end
  end
end
