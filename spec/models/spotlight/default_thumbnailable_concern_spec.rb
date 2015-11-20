require 'spec_helper'

describe Spotlight::DefaultThumbnailable do
  let(:test_class) { Class.new }
  subject { test_class.new }
  before { subject.extend(described_class) }

  it 'invokes DefaultThumbnailJob job' do
    expect(Spotlight::DefaultThumbnailJob).to receive(:perform_later).with(subject)
    subject.send(:fetch_default_thumb_later)
  end

  it 'raises a NotImplementedError if the class does not have a set_default_thumbnail method' do
    expect do
      subject.send(:set_default_thumbnail)
    end.to raise_error(NotImplementedError)
  end
end
