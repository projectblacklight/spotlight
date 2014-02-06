require 'spec_helper'

describe SolrDocument do
  subject { SolrDocument.new(id: 'abcd123') }
  its(:to_key) {should == ['abcd123']}
  its(:persisted?) {should be_true}

  its(:tags) {should == [] }

  it "should be able to add tags" do
    subject.taggings.should == []
    expect {
      subject.tag_list= "awesomer, slicker"
      subject.save
    }.to change { ActsAsTaggableOn::Tag.count}.by(2)
    subject.tag_list.should == ['awesomer', 'slicker']
  end
end

