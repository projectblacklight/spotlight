require 'spec_helper'

describe SolrDocument do
  subject { ::SolrDocument.new(id: 'abcd123') }
  its(:to_key) {should == ['abcd123']}
  its(:persisted?) {should be_true}

  its(:tags) {should == [] }

  it "should be able to add tags" do
    subject.taggings.should eq []
    expect {
      subject.update Spotlight::Exhibit.default, tag_list: "awesomer, slicker"
      subject.save
    }.to change { ActsAsTaggableOn::Tag.count}.by(2)
    subject.tag_list.should eq ['awesomer', 'slicker']
  end

  it "should have find" do
    expect(::SolrDocument.find('dq287tq6352')).to be_kind_of SolrDocument
  end

  describe "#sidebar" do
    it "should return a sidecar for adding exhibit-specific fields" do
      expect(subject.sidecar(Spotlight::Exhibit.default)).to be_kind_of Spotlight::SolrDocumentSidecar
    end
  end

  describe "#update" do
    it "should store sidecar data on the sidecar object" do
      mock_sidecar = double
      subject.stub(sidecar: mock_sidecar)
      mock_sidecar.should_receive(:update).with(data: { 'a' => 1 })
      subject.update Spotlight::Exhibit.default, sidecar: { data: { 'a' => 1 }}
    end
  end
end

