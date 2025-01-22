# frozen_string_literal: true

RSpec.describe Translation, type: :model do
  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe 'is unique by key, locale, and exhibit' do
    it 'fails validation' do
      described_class.create(exhibit_id: exhibit.id, key: 'abc', locale: 'fr', value: 'yo')
      expect do
        described_class.create(exhibit_id: exhibit.id, key: 'abc', locale: 'fr', value: 'lo')
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe '.to_h' do
    it 'dumps the translations' do
      expect(described_class.to_h).to be_a(Hash)
    end
  end

  describe '.to_hash' do
    it 'is not defined' do
      expect(described_class).not_to respond_to(:to_hash)
    end
  end
end
