require 'spec_helper'

describe SolrDocument, type: :model do
  subject { ::SolrDocument.new(id: 'abcd123') }
  its(:to_key) { should == ['abcd123'] }
  its(:persisted?) { should be_truthy }
  before do
    allow(subject).to receive_messages(reindex: nil)
  end

  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_alt) { FactoryGirl.create(:exhibit) }

  it 'has tags on the exhibit' do
    expect(subject.tags_from(exhibit)).to be_empty
  end

  it 'is able to add tags' do
    expect do
      exhibit.tag(subject, with: 'paris, normandy', on: :tags)
    end.to change { ActsAsTaggableOn::Tag.count }.by(2)
    expect(subject.tags_from(exhibit)).to eq %w(paris normandy)
  end

  it 'has find' do
    expect(::SolrDocument.find('dq287tq6352')).to be_kind_of described_class
  end

  it 'has ==' do
    expect(::SolrDocument.find('dq287tq6352')).to eq ::SolrDocument.find('dq287tq6352')
  end

  describe 'GlobalID' do
    let(:doc_id) { 'dq287tq6352' }
    it 'responds to #to_global_id' do
      expect(::SolrDocument.find(doc_id).to_global_id.to_s).to eq "gid://internal/SolrDocument/#{doc_id}"
    end
    it 'is able to locate SolrDocuments by their GlobalID' do
      expect(GlobalID::Locator.locate(
        ::SolrDocument.find(doc_id).to_global_id
      )['id']).to eq doc_id
    end
  end

  describe '#sidecar' do
    it 'returns a sidecar for adding exhibit-specific fields' do
      expect(subject.sidecar(exhibit)).to be_kind_of Spotlight::SolrDocumentSidecar
      expect(subject.sidecar(exhibit).exhibit).to eq exhibit
    end

    it 'keeps distinct sidecars for each exhibit' do
      expect(subject.sidecar(exhibit).exhibit).to eq exhibit
      expect(subject.sidecar(exhibit_alt).exhibit).to eq exhibit_alt
    end
  end

  describe '#update' do
    it 'stores sidecar data on the sidecar object' do
      mock_sidecar = double
      allow(subject).to receive_messages(sidecar: mock_sidecar)
      expect(mock_sidecar).to receive(:update).with(data: { 'a' => 1 })
      subject.update exhibit, sidecar: { data: { 'a' => 1 } }
    end
    it 'stores tags' do
      subject.update exhibit, exhibit_tag_list: 'paris, normandy'
      expect(subject.tags_from(exhibit)).to eq %w(paris normandy)
    end
  end

  describe '#to_solr' do
    before do
      Spotlight::SolrDocumentSidecar.create! document: subject, exhibit: exhibit,
                                             data: { 'a_tesim' => 1, 'b_tesim' => 2, 'c_tesim' => 3 }
    end

    it 'includes the doc id' do
      expect(subject.to_solr[:id]).to eq 'abcd123'
    end

    it 'includes exhibit-specific tags' do
      exhibit.tag(subject, with: 'paris', on: :tags)

      expect(subject.to_solr).to include :exhibit_1_tags_ssim
      expect(subject.to_solr[:exhibit_1_tags_ssim]).to include 'paris'
    end

    it "includes placeholders for all exhibits' tags" do
      expect(subject.to_solr).to include :exhibit_1_tags_ssim
      expect(subject.to_solr[:exhibit_1_tags_ssim]).to eq nil
    end

    it 'includes sidecar fields' do
      expect(subject.to_solr).to include('a_tesim' => 1, 'b_tesim' => 2, 'c_tesim' => 3)
    end
  end

  describe '#public?' do
    it 'defaults to public' do
      expect(subject).to be_public exhibit
    end
  end

  describe '#private?' do
    it 'defaults to public' do
      expect(subject).not_to be_private exhibit
    end
  end

  describe '#make_public!' do
    it 'sets the object to public' do
      allow(subject).to receive(:reindex)
      subject.make_public! exhibit
      expect(subject).not_to be_private exhibit
    end

    it 'augments existing sidecar data' do
      allow(subject).to receive(:reindex)

      subject.update exhibit, sidecar: { data: { a: 1 } }
      subject.make_public! exhibit
      expect(subject.sidecar(exhibit).data[:a]).to eq 1
    end
  end

  describe '#make_private!' do
    it 'sets the object to private' do
      allow(subject).to receive(:reindex)
      subject.make_private! exhibit
      expect(subject).to be_private exhibit
    end
  end

  describe 'uploaded resources' do
    let(:uploaded_resource) do
      described_class.new(
        spotlight_resource_type_ssim: 'spotlight/resources/uploads'
      )
    end
    it 'does not include Spotlight::SolrDocument::UploadedResource when the correct fields are present' do
      expect(subject).to_not be_kind_of Spotlight::SolrDocument::UploadedResource
    end
    it 'includes Spotlight::SolrDocument::UploadedResource when the correct fields are present' do
      expect(uploaded_resource).to be_kind_of Spotlight::SolrDocument::UploadedResource
    end
    describe '#uploaded_resource?' do
      it 'returns false if the correct fields are not present' do
        expect(subject).to_not be_uploaded_resource
      end
      it 'returns true when the correct fields are present' do
        expect(uploaded_resource).to be_uploaded_resource
      end
    end
  end
end
