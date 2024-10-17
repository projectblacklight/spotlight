# frozen_string_literal: true

describe Spotlight::Group, type: :model do
  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe '#searches' do
    let(:group) { FactoryBot.create(:group_with_searches, exhibit:, searches_count: 4) }

    it do
      expect(group.searches.count).to eq 4
    end

    it do
      group.searches.all do |search|
        expect(search).to be_an Spotlight::Search
      end
    end
  end
end
