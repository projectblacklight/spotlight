require 'spec_helper'

describe Spotlight::SolrDocumentSidecar do
  before do
    subject.stub exhibit: Spotlight::Exhibit.default
    subject.stub solr_document_id: 'doc_id'
  end

  describe "#to_solr" do
    before do
      subject.data = { a: 1, b: 2, c: 3 }
    end

    its(:to_solr) { should include id: 'doc_id' }
    its(:to_solr) { should include exhibit_1_public_bsi: true }
    its(:to_solr) { should include 'a_tesim', 'b_tesim', 'c_tesim' }
  end

end