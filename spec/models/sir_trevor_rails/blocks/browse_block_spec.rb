# frozen_string_literal: true

describe SirTrevorRails::Blocks::BrowseBlock do
  let(:page) { FactoryBot.create(:feature_page) }
  let(:block_data) { {} }
  subject { described_class.new({ type: '', data: block_data }, page) }

  describe '#items' do
    it 'is the array of items with display set to true' do
      block_data[:item] = {
        '0': { id: 'abc123', display: 'true' },
        '1': { id: 'xyz321', display: 'false' }
      }
      expect(subject.items.length).to eq 1
      expect(subject.items).to eq([{ id: 'abc123', display: 'true' }])
    end

    it 'is an empty array when there is no browse category' do
      expect(subject.items).to eq([])
    end
  end

  describe '#as_json' do
    context 'when no items are present' do
      it 'returns an empty items value' do
        block_data[:item] = nil
        expect(subject.as_json[:data]).to include item: {}
      end
    end

    context 'when the id of a browse category does not exist' do
      it 'is not included the returned items hash' do
        search = FactoryBot.create(:search, exhibit: page.exhibit)
        block_data[:item] = { item_0: { 'id' => 'abc123' }, item_1: { 'id' => search.slug } }

        expect(subject.as_json[:data][:item]).not_to have_key :item_0
        expect(subject.as_json[:data][:item]).to have_key :item_1
      end
    end
  end
end
