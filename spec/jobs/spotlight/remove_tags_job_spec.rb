# frozen_string_literal: true

describe Spotlight::RemoveTagsJob do
  subject { described_class.new(solr_params: solr_params, exhibit: exhibit, tags: tags) }

  let(:solr_params) { { q: 'map' } }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:tags) { %w[hello world] }

  before do
    allow(Spotlight::Engine.config).to receive_messages(bulk_actions_batch_size: 5)
  end

  it 'removes tags from SolrDocumentSidecar objects' do
    response = exhibit.blacklight_config.repository.search(solr_params.merge('rows' => 999_999_999))
    expect(response.total).to eq 55
    response.documents.each do |document|
      exhibit.tag(document.sidecar(exhibit), with: %w[hello world], on: :tags)
      document.reindex
    end
    subject.perform_now
    response = exhibit.blacklight_config.repository.search(solr_params.merge('rows' => 999_999_999))
    expect(response.total).to eq 55
    expect(Spotlight::JobTracker.last).to have_attributes(
      status: 'completed',
      total: 55,
      progress: 55,
      job_class: 'Spotlight::RemoveTagsJob'
    )
    response.documents.each do |document|
      expect(document.sidecar(exhibit).all_tags_list).to eq []
    end
    exhibit.owned_tags.destroy_all
    response.documents.each do |document|
      document.sidecar(exhibit).destroy
      document.reindex
    end
  end
end
