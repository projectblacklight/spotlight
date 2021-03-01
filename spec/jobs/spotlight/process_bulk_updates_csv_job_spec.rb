# frozen_string_literal: true

def tag_names(exhibit, id)
  exhibit.blacklight_config.repository.find(id).documents.first.sidecar(exhibit).taggings.includes(:tag).map { |tagging| tagging&.tag&.name }
end

describe Spotlight::ProcessBulkUpdatesCsvJob do
  subject { described_class.new(exhibit, bulk_update) }

  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe 'visibility' do
    let(:bulk_update) { FactoryBot.create(:bulk_update, exhibit: exhibit) }

    it 'is updated' do
      expect(exhibit.blacklight_config.repository.find('dq287tq6352').documents.first).not_to be_private(exhibit)
      subject.perform_now
      expect(exhibit.blacklight_config.repository.find('dq287tq6352').documents.first).to be_private(exhibit)
    end
  end

  describe 'tags' do
    let(:bulk_update) { FactoryBot.create(:tagged_bulk_update, exhibit: exhibit) }

    before do
      document = exhibit.blacklight_config.repository.find('cz507zk0531').documents.first
      exhibit.tag(document.sidecar(exhibit), with: 'CSV Tag1', on: :tags)
    end

    it 'are added/removed' do
      expect(tag_names(exhibit, 'bm387cy2596')).to be_empty
      expect(tag_names(exhibit, 'cz507zk0531')).to eq(['CSV Tag1'])
      expect(tag_names(exhibit, 'dq287tq6352')).to be_empty
      subject.perform_now
      expect(tag_names(exhibit, 'bm387cy2596')).to eq(['CSV Tag1', 'CSV Tag2'])
      expect(tag_names(exhibit, 'cz507zk0531')).to eq(['CSV Tag2'])
      expect(tag_names(exhibit, 'dq287tq6352')).to eq(['CSV Tag1', 'CSV Tag2'])
    end
  end
end
