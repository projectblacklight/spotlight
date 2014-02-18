require 'spec_helper'

describe Spotlight::SolrDocument::AtomicUpdates do
  let(:blacklight_solr) { double }
  subject do
    ::SolrDocument.new.extend(Spotlight::SolrDocument::AtomicUpdates)
  end

  before do
    subject.stub(blacklight_solr: blacklight_solr)
  end

  describe "#reindex" do
    before do
      subject.stub(to_solr: { id: 'doc_id', a: 1, b: 2 })
    end

    it "should send an atomic update request" do
      blacklight_solr.should_receive(:update).with(params: { commitWithin: 500 }, data: [{id: 'doc_id', a: { set: 1 }, b: { set: 2 }}].to_json, headers: { 'Content-Type' => 'application/json'})
      subject.reindex
    end

    it "should cowardly refuse to index a document if the only value is an id" do
      subject.stub(to_solr: { id: 'doc_id' })
      blacklight_solr.should_not_receive(:update)
      subject.reindex
    end
  end
end