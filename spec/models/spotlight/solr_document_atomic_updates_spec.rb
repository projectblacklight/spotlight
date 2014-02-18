require 'spec_helper'

describe Spotlight::SolrDocument::AtomicUpdates do
  let(:blacklight_solr) { double }
  subject do
    ::SolrDocument.new.extend(Spotlight::SolrDocument::AtomicUpdates)
  end

  describe "#reindex" do
    before do
      subject.stub(blacklight_solr: blacklight_solr)
      subject.stub(to_solr: { id: 'doc_id', a: 1, b: 2 })
    end

    it "should send an atomic update request" do
      blacklight_solr.should_receive(:update).with(data: {id: 'doc_id', a: { set: 1 }, b: { set: 2 }}.to_json, headers: { 'Content-Type' => 'application/json'})
      subject.reindex
    end
  end
end