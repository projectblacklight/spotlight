require 'spec_helper'

describe Spotlight::Site do
  describe '.instance' do
    it 'is a singleton' do
      expect(described_class.instance).to eq described_class.instance
    end
  end
end
