require 'spec_helper'

describe Spotlight::Masthead, type: :model do
  describe '#masthead_exists?' do
    let(:masthead) { stub_model(described_class) }
    let(:image) { OpenStruct.new }
    it 'returns false when the masthead is set to not display' do
      expect(masthead.display?).to be_falsey
    end
    it 'returns false when the cropped image is not present' do
      masthead.display = true
      expect(masthead.display?).to be_falsey
    end
    it 'returns false when the cropped image is present but the masthead is set to not display' do
      allow(masthead).to receive(:image).and_return(image)
      allow(image).to receive(:cropped).and_return([0])
      expect(masthead.display?).to be_falsey
    end
    it 'returns true when the cropped image is present and the masthead is set to display' do
      masthead.display = true
      expect(masthead).to receive(:image).and_return(image)
      expect(image).to receive(:cropped).and_return([0])
      expect(masthead.display?).to be_truthy
    end
  end
end
