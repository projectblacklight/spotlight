require 'rails_helper'

describe Spotlight::Resources::IiifHarvester do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  subject { described_class.create(exhibit_id: exhibit.id, url: url) }

  describe 'Validation' do
    context 'when given an invalid URL' do
      let(:url) { 'http://example.com' }

      it 'errors when the URL is not a IIIF URL' do
        expect(subject).to_not be_valid
        expect(subject.errors).to be_present
        expect(subject.errors[:url]).to eq ['Invalid IIIF URL']
      end
    end
  end

  describe '#to_solr' do
    let(:url) { 'uri://for-top-level-collection' }
    before { stub_default_collection }

    it 'returns an Enumerator of all the solr documents' do
      expect(subject.to_solr).to be_a(Enumerator)
      expect(subject.to_solr.count).to eq 4
    end

    it 'all solr documents include exhibit context' do
      subject.to_solr.each do |doc|
        expect(doc).to have_key("spotlight_exhibit_slug_#{exhibit.slug}_bsi")
      end
    end
  end
end
