require 'spec_helper'

describe SolrDocument do
  subject { ::SolrDocument.new(id: 'abcd123') }
  its(:to_key) {should == ['abcd123']}
  its(:persisted?) {should be_true}

  its(:tags) {should == [] }

  it "should be able to add tags" do
    subject.taggings.should eq []
    expect {
      subject.update tag_list: "awesomer, slicker"
      subject.save
    }.to change { ActsAsTaggableOn::Tag.count}.by(2)
    subject.tag_list.should eq ['awesomer', 'slicker']
  end

  it "should have find" do
    expect(::SolrDocument.find('dq287tq6352')).to be_kind_of SolrDocument
  end
end

