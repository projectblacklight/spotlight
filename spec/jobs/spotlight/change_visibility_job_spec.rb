# frozen_string_literal: true

describe Spotlight::ChangeVisibilityJob do
  subject { described_class.new(solr_params: solr_params, exhibit: exhibit, visibility: visibility) }

  let(:solr_params) { { q: 'map' } }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:visibility) { 'private' }

  it 'sets the items based off of the visibility' do
    subject.perform_now
    response = exhibit.blacklight_config.repository.search(solr_params.merge('rows' => 999_999_999))
    expect(response.total).to eq 55
    response.documents.each do |document|
      expect(document.private?(exhibit)).to be true
      document.make_public!(exhibit)
      document.reindex
    end
  end
end
