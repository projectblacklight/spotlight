# frozen_string_literal: true

RSpec.describe Spotlight::DefaultThumbnailJob do
  subject { described_class.new(thumbnailable) }

  let(:thumbnailable) { thumbnailable_class.new }
  let(:thumbnailable_class) do
    Class.new do
      def set_default_thumbnail; end
      def save; end
    end
  end

  it 'calls #set_default_thumbnail on the object passed in and saves' do
    expect(thumbnailable).to receive(:set_default_thumbnail)
    expect(thumbnailable).to receive(:save)

    subject.perform_now
  end
end
