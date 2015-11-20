require 'spec_helper'

describe Spotlight::DefaultThumbnailJob do
  let(:thumbnailable) { double('Thumbnailable') }
  subject { described_class.new(thumbnailable) }

  it 'calls #set_default_thumbnail on the object passed in and saves' do
    expect(thumbnailable).to receive(:set_default_thumbnail)
    expect(thumbnailable).to receive(:save)

    subject.perform_now
  end
end
