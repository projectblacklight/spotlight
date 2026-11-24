# frozen_string_literal: true

RSpec.describe Spotlight::Site do
  describe '.instance' do
    it 'is a singleton' do
      site = described_class.instance

      expect(described_class.instance).to eq site
    end
  end
end
