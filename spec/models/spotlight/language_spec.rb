# frozen_string_literal: true

RSpec.describe Spotlight::Language do
  describe '#to_native' do
    it 'is the native translation of the locale' do
      expect(described_class.new(locale: 'de').to_native).to eq 'Deutsch'
    end

    it 'is a blank string when the locale does not exist (for string comparison)' do
      expect(described_class.new(locale: 'xx').to_native).to eq ''
    end
  end
end
