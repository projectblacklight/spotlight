require 'spec_helper'

describe Spotlight::SolrDocumentSidecar, type: :model do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  before do
    allow(subject).to receive_messages exhibit: exhibit
    allow(subject).to receive_messages document: SolrDocument.new(id: 'doc_id')
  end

  describe '#to_solr' do
    before do
      subject.data = { 'a_tesim' => 1, 'b_tesim' => 2, 'c_tesim' => 3 }
    end

    its(:to_solr) { should include id: 'doc_id' }
    its(:to_solr) { should include "exhibit_#{exhibit.slug}_public_bsi".to_sym => true }
    its(:to_solr) { should include 'a_tesim', 'b_tesim', 'c_tesim' }
  end
end
