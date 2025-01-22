# frozen_string_literal: true

RSpec.describe Spotlight::DefaultThumbnailJob do
  subject { described_class.new(thumbnailable) }

  let(:thumbnailable) { double('Thumbnailable') }

  it 'calls #set_default_thumbnail on the object passed in and saves' do
    expect(thumbnailable).to receive(:set_default_thumbnail)
    expect(thumbnailable).to receive(:save)

    subject.perform_now
  end
end
