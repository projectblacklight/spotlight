require 'spec_helper'

describe Spotlight::RenameSidecarFieldJob do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:sidecar) { SolrDocument.new(id: 'test').sidecar(exhibit).tap(&:save!) }

  it 'updates the sidecar data and reindex affected documents' do
    expect_any_instance_of(::SolrDocument).to receive(:reindex)

    sidecar.data['old_field'] = 'some value'
    sidecar.save!

    described_class.perform_later(exhibit, 'old_field', 'new_field')

    sidecar.reload
    expect(sidecar.data['new_field']).to eq 'some value'
  end

  it 'does not touch unaffected documents' do
    expect_any_instance_of(::SolrDocument).not_to receive(:reindex)

    sidecar.data['other_field'] = 'some value'
    sidecar.save!

    described_class.perform_later(exhibit, 'old_field', 'new_field')
  end
end
