# frozen_string_literal: true

RSpec.describe Spotlight::ExhibitSearch do
  subject(:search) { described_class.new(query) }

  let(:exhibit) do
    FactoryBot.build(:exhibit, title: 'Some Exhibit Title', subtitle: 'Some Subtitle',
                               description: 'Some <strong>description</strong> AT&amp;T')
  end
  let(:other_exhibit) { FactoryBot.build(:exhibit, title: 'Other Title', subtitle: nil, description: 'Été') }
  let(:exhibits) { [exhibit, other_exhibit] }

  describe '#filter' do
    context 'with words from different fields, in any order' do
      let(:query) { 'subtitle description exhibit' }

      it 'returns the exhibits that contain every word' do
        expect(search.filter(exhibits)).to eq [exhibit]
      end
    end

    context 'with one word that does not match' do
      let(:query) { 'exhibit other' }

      it 'returns no exhibits' do
        expect(search.filter(exhibits)).to be_empty
      end
    end

    context 'with part of a word' do
      let(:query) { 'exhib' }

      it 'returns the matching exhibits' do
        expect(search.filter(exhibits)).to eq [exhibit]
      end
    end

    context 'with a different case, outside ASCII' do
      let(:query) { 'ÉTÉ' }

      it 'returns the matching exhibits' do
        expect(search.filter(exhibits)).to eq [other_exhibit]
      end
    end

    context 'with an HTML tag name from the description' do
      let(:query) { 'strong' }

      it 'does not match the markup' do
        expect(search.filter(exhibits)).to be_empty
      end
    end

    context 'with a character that the description encodes as an HTML entity' do
      let(:query) { 'at&t' }

      it 'matches the decoded text' do
        expect(search.filter(exhibits)).to eq [exhibit]
      end
    end

    context 'with a word that more than one exhibit contains' do
      let(:query) { 'title' }

      it 'keeps the order of the given exhibits' do
        expect(search.filter([other_exhibit, exhibit])).to eq [other_exhibit, exhibit]
      end
    end

    context 'with a blank query' do
      let(:query) { '   ' }

      it 'returns the given exhibits unchanged' do
        expect(search.filter(exhibits)).to equal exhibits
      end
    end
  end

  describe '#active?' do
    it 'is false for a blank query' do
      expect(described_class.new(nil)).not_to be_active
    end

    it 'is true for a query with words' do
      expect(described_class.new('exhibit')).to be_active
    end
  end

  describe '#query' do
    let(:query) { "  some \n exhibit  " }

    it 'collapses extra whitespace' do
      expect(search.query).to eq 'some exhibit'
    end
  end
end
