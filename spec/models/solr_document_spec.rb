require 'spec_helper'

describe SolrDocument, :type => :model do
  subject { ::SolrDocument.new(id: 'abcd123') }
  its(:to_key) {should == ['abcd123']}
  its(:persisted?) {should be_truthy}
  before do
    allow(subject).to receive_messages(reindex: nil)
  end

  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_alt) { FactoryGirl.create(:exhibit) }

  it "should have tags on the exhibit" do
    expect(subject.tags_from(exhibit)).to be_empty
  end

  it "should be able to add tags" do
    expect {
      exhibit.tag(subject, with: "paris, normandy", on: :tags)
    }.to change { ActsAsTaggableOn::Tag.count}.by(2)
    expect(subject.tags_from(exhibit)).to eq ['paris', 'normandy']
  end

  it "should have find" do
    expect(::SolrDocument.find('dq287tq6352')).to be_kind_of SolrDocument
  end

  it "should have ==" do
    expect(::SolrDocument.find('dq287tq6352')).to eq ::SolrDocument.find('dq287tq6352')
  end

  describe "#sidecar" do
    it "should return a sidecar for adding exhibit-specific fields" do
      expect(subject.sidecar(exhibit)).to be_kind_of Spotlight::SolrDocumentSidecar
      expect(subject.sidecar(exhibit).exhibit).to eq exhibit
    end
    
    it "should keep distinct sidecars for each exhibit" do
      expect(subject.sidecar(exhibit).exhibit).to eq exhibit
      expect(subject.sidecar(exhibit_alt).exhibit).to eq exhibit_alt
    end
  end

  describe "#update" do
    it "should store sidecar data on the sidecar object" do
      mock_sidecar = double
      allow(subject).to receive_messages(sidecar: mock_sidecar)
      expect(mock_sidecar).to receive(:update).with(data: { 'a' => 1 })
      subject.update exhibit, sidecar: { data: { 'a' => 1 }}
    end
    it "should store tags" do
      subject.update exhibit, exhibit_tag_list: "paris, normandy"
      expect(subject.tags_from(exhibit)).to eq ['paris', 'normandy']
    end
  end

  describe "#to_solr" do
    before do
      Spotlight::SolrDocumentSidecar.create! solr_document: subject, exhibit: exhibit,
        data: {'a_tesim' => 1, 'b_tesim' => 2, 'c_tesim' => 3 }
    end

    it "should include the doc id" do
      expect(subject.to_solr[:id]).to eq 'abcd123' 
    end

    it "should include exhibit-specific tags" do
      exhibit.tag(subject, with: 'paris', on: :tags)

      expect(subject.to_solr).to include :exhibit_1_tags_ssim
      expect(subject.to_solr[:exhibit_1_tags_ssim]).to include 'paris'
    end

    it "should include placeholders for all exhibits' tags" do
      expect(subject.to_solr).to include :exhibit_1_tags_ssim
      expect(subject.to_solr[:exhibit_1_tags_ssim]).to eq nil
    end

    it "should include sidecar fields" do
      expect(subject.to_solr).to include('a_tesim' => 1, 'b_tesim' => 2, 'c_tesim' => 3)
    end
  end

  describe "#public?" do
    it "should default to public" do
      expect(subject).to be_public exhibit
    end
  end

  describe "#private?" do
    it "should default to public" do
      expect(subject).not_to be_private exhibit
    end
  end

  describe "#make_public!" do
    it "should set the object to public" do
      allow(subject).to receive(:reindex)
      subject.make_public! exhibit
      expect(subject).not_to be_private exhibit
    end

    it "should augment existing sidecar data" do
      allow(subject).to receive(:reindex)

      subject.update exhibit, sidecar: { data: { a: 1}} 
      subject.make_public! exhibit
      expect(subject.sidecar(exhibit).data[:a]).to eq 1
    end
  end

  describe "#make_private!" do
    it "should set the object to private" do
      allow(subject).to receive(:reindex)
      subject.make_private! exhibit
      expect(subject).to be_private exhibit
    end
  end
end
