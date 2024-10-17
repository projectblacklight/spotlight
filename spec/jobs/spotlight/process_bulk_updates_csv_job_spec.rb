# frozen_string_literal: true

def tag_names(exhibit, id)
  exhibit.blacklight_config.repository.find(id).documents.first.sidecar(exhibit).taggings.includes(:tag).map { |tagging| tagging&.tag&.name }
end

describe Spotlight::ProcessBulkUpdatesCsvJob do
  subject { described_class.new(exhibit, bulk_update) }

  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe 'visibility' do
    let(:bulk_update) { FactoryBot.create(:bulk_update, exhibit:) }

    it 'is updated' do
      allow(SolrDocument.index.connection).to receive(:update).and_call_original
      expect(exhibit.blacklight_config.repository.find('dq287tq6352').documents.first).not_to be_private(exhibit)

      subject.perform_now

      expect(exhibit.blacklight_config.repository.find('dq287tq6352').documents.first).to be_private(exhibit)
      expect(SolrDocument.index.connection).to have_received(:update)
    end

    context 'with a row that does not change visibility' do
      before do
        sidecar = exhibit.solr_document_sidecars.find_or_create_by(document_type: 'SolrDocument', document_id: 'dq287tq6352')
        sidecar.private!
      end

      it 'does not update solr' do
        allow(SolrDocument.index.connection).to receive(:update)

        subject.perform_now

        expect(SolrDocument.index.connection).not_to have_received(:update)
      end
    end

    context 'without a visibility column' do
      let(:bulk_update) { FactoryBot.create(:bulk_update_no_cols, exhibit:) }

      it 'does nothing with the data' do
        expect { subject.perform_now }.not_to(change { exhibit.reload.solr_document_sidecars.where(public: false).count })
      end
    end
  end

  describe 'tags' do
    let(:bulk_update) { FactoryBot.create(:tagged_bulk_update, exhibit:) }

    before do
      document = exhibit.blacklight_config.repository.find('cz507zk0531').documents.first
      exhibit.tag(document.sidecar(exhibit), with: 'CSV Tag1', on: :tags)
    end

    it 'are added/removed' do
      allow(SolrDocument.index.connection).to receive(:update).and_call_original
      expect(tag_names(exhibit, 'bm387cy2596')).to be_empty
      expect(tag_names(exhibit, 'cz507zk0531')).to eq(['CSV Tag1'])
      expect(tag_names(exhibit, 'dq287tq6352')).to be_empty
      subject.perform_now
      expect(tag_names(exhibit, 'bm387cy2596')).to eq(['CSV Tag1', 'CSV Tag2'])
      expect(tag_names(exhibit, 'cz507zk0531')).to eq(['CSV Tag2'])
      expect(tag_names(exhibit, 'dq287tq6352')).to eq(['CSV Tag1', 'CSV Tag2'])

      # 3 updates plus the final commit
      expect(SolrDocument.index.connection).to have_received(:update).exactly(4).times
    end

    context 'with a row that does not change visibility' do
      before do
        # set up the documents to match what's the in the spreadsheet already
        subject.perform_now
      end

      it 'does not update solr' do
        allow(SolrDocument.index.connection).to receive(:update)

        subject.perform_now

        expect(SolrDocument.index.connection).not_to have_received(:update)
      end
    end
  end
end
