require 'spec_helper'

describe SolrDocument, type: :model do
  subject { described_class.new(id: 'abcd123') }
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
    expect(described_class.find('dq287tq6352')).to be_kind_of described_class
  end

  it 'has ==' do
    expect(described_class.find('dq287tq6352')).to eq described_class.find('dq287tq6352')
  end

  describe 'GlobalID' do
    let(:doc_id) { 'dq287tq6352' }
    it 'responds to #to_global_id' do
      expect(described_class.find(doc_id).to_global_id.to_s).to eq "gid://internal/SolrDocument/#{doc_id}"
    end
    it 'is able to locate SolrDocuments by their GlobalID' do
      expect(GlobalID::Locator.locate(
        described_class.find(doc_id).to_global_id
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

      expect(subject.to_solr).to include :"exhibit_#{exhibit.slug}_tags_ssim"
      expect(subject.to_solr[:"exhibit_#{exhibit.slug}_tags_ssim"]).to include 'paris'
    end

    it "includes placeholders for all exhibits' tags" do
      expect(subject.to_solr).to include :"exhibit_#{exhibit.slug}_tags_ssim"
      expect(subject.to_solr[:"exhibit_#{exhibit.slug}_tags_ssim"]).to eq nil
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

  describe '.find_each' do
    it 'enumerates the documents in the exhibit' do
      expect(described_class.find_each).to be_a Enumerable
    end

    it 'pages through the index' do
      allow_any_instance_of(Blacklight::Solr::Repository).to receive(:search).with(hash_including(start: 0)).and_return(double(documents: [1, 2, 3]))
      allow_any_instance_of(Blacklight::Solr::Repository).to receive(:search).with(hash_including(start: 3)).and_return(double(documents: [4, 5, 6]))
      allow_any_instance_of(Blacklight::Solr::Repository).to receive(:search).with(hash_including(start: 6)).and_return(double(documents: []))

      expect(described_class.find_each.to_a).to match_array [1, 2, 3, 4, 5, 6]
    end
  end

  describe '.reindex_all' do
    let(:doc) { described_class.new id: 1 }

    it 'reindexes all solr documents' do
      expect(described_class).to receive(:find_each).and_yield(doc)
      expect(doc).to receive(:reindex)

      described_class.reindex_all
    end
  end
end
