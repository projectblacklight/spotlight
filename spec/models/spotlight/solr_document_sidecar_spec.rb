require 'spec_helper'

describe Spotlight::SolrDocumentSidecar do
  before do
    subject.stub solr_document_id: 'doc_id'
  end

  describe "#to_solr" do
    before do
      subject.data = { a: 1, b: 2, c: 3 }
    end

    its(:to_solr) { should include id: 'doc_id' }
    its(:to_solr) { should include :a, :b, :c }
  end
end