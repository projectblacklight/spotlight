# frozen_string_literal: true

RSpec.describe Spotlight::AddTagsJob do
  subject { described_class.new(solr_params:, exhibit:, tags:) }

  let(:solr_params) { { q: 'map' } }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:tags) { 'hello,world' }

  before do
    allow(Spotlight::Engine.config).to receive_messages(bulk_actions_batch_size: 5)
  end

  it 'adds tags to SolrDocumentSidecar objects' do
    subject.perform_now
    response = exhibit.blacklight_config.repository.search(solr_params.merge('rows' => 999_999_999))
    expect(response.total).to eq 55
    expect(Spotlight::JobTracker.last).to have_attributes(
      status: 'completed',
      total: 55,
      progress: 55,
      job_class: 'Spotlight::AddTagsJob'
    )
    response.documents.each do |document|
      expect(document.sidecar(exhibit).all_tags_list).to include('hello', 'world')
      exhibit.tag(document.sidecar(exhibit), with: [], on: :tags)
    end
    exhibit.owned_tags.destroy_all
    response.documents.each do |document|
      document.sidecar(exhibit).destroy
      document.reindex
    end
  end
end
