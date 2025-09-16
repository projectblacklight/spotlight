# frozen_string_literal: true

module WithQueueAdapter
  def with_queue_adapter(new_adapter)
    around do |example|
      old_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = new_adapter
      example.run
    ensure
      ActiveJob::Base.queue_adapter = old_adapter
    end
  end
end

RSpec.configure do |config|
  config.extend WithQueueAdapter
end
