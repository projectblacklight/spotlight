# frozen_string_literal: true

RSpec.describe Spotlight::ChangeVisibilityJob do
  subject { described_class.new(solr_params:, exhibit:, visibility:) }

  let(:solr_params) { { q: 'map' } }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:visibility) { 'private' }

  before do
    allow(Spotlight::Engine.config).to receive_messages(bulk_actions_batch_size: 5)
  end

  it 'sets the items based off of the visibility' do
    subject.perform_now
    response = exhibit.blacklight_config.repository.search(solr_params.merge('rows' => 999_999_999))
    expect(response.total).to eq 55
    expect(Spotlight::JobTracker.last).to have_attributes(
      status: 'completed',
      total: 55,
      progress: 55,
      job_class: 'Spotlight::ChangeVisibilityJob'
    )
    response.documents.each do |document|
      expect(document.private?(exhibit)).to be true
      document.make_public!(exhibit)
      document.reindex
    end
  end
end
