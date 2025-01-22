# frozen_string_literal: true

RSpec.describe SirTrevorRails::Blocks::BrowseGroupCategoriesBlock do
  subject { described_class.new({ type: '', data: block_data }, page) }

  let!(:exhibit) { FactoryBot.create(:exhibit) }
  let!(:page) { FactoryBot.create(:feature_page, exhibit:) }
  let!(:group1) { FactoryBot.create(:group, exhibit:, title: 'abc123', published: true) }
  let!(:group2) { FactoryBot.create(:group, exhibit:, title: 'xyz321', published: true) }

  let(:block_data) { {} }

  describe '#groups' do
    it 'is the array of items with display set to true' do
      block_data[:item] = {
        '0': { id: 'abc123', display: 'true', weight: '2' },
        '1': { id: 'xyz321', display: 'true', weight: '1' }
      }
      expect(subject.groups.length).to eq 2
      expect(subject.groups.first.title).to eq 'xyz321'
    end
  end

  describe '#groups?' do
    it 'is the array of items with display set to true' do
      block_data[:item] = {}
      expect(subject.be_groups).to be_falsy
    end
  end

  describe '#display_item_counts?' do
    it do
      expect(subject).not_to be_display_item_counts
    end

    it do
      block_data['display-item-counts'] = 'true'
      expect(subject).to be_display_item_counts
    end
  end
end
