# frozen_string_literal: true

RSpec.describe SirTrevorRails::Blocks::FeaturedPagesBlock do
  subject { described_class.new({ type: '', data: block_data }, page) }

  let(:page) { FactoryBot.create(:feature_page, exhibit:) }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:block_data) { {} }

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

  describe '#pages' do
    let!(:page_a) { FactoryBot.create(:feature_page, slug: 'a', exhibit:) }
    let!(:translated_page_a) { page_a.clone_for_locale('a').tap { |x| x.update(published: true) && x.save } }
    let!(:page_b) { FactoryBot.create(:feature_page, slug: 'b', exhibit:) }

    before do
      block_data[:item] = {
        '0': { id: 'a', display: 'true' },
        '1': { id: 'b', display: 'true' }
      }
    end

    it 'retrieves the pages from the default locale' do
      expect(subject.pages.length).to eq 2
    end
  end

  describe '#as_json' do
    context 'when no items are present' do
      it 'returns an empty items value' do
        block_data[:item] = nil
        expect(subject.as_json[:data]).to include item: {}
      end
    end
  end
end
