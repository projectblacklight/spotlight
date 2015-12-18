require 'spec_helper'

describe Spotlight::Search, type: :model do
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  let(:query_params) { { 'f' => { 'genre_sim' => ['map'] } } }
  subject { exhibit.searches.build(title: 'Search', query_params: query_params) }

  let(:blacklight_config) { ::CatalogController.blacklight_config }
  let(:document) do
    SolrDocument.new(id: 'dq287tq6352',
                     blacklight_config.index.title_field => 'title',
                     Spotlight::Engine.config.full_image_field => 'https://stacks.stanford.edu/image/iiif/dq287tq6352%2Fdq287tq6352_05_0001/full/!400,400/0/default.jpg')
  end
  let(:document_without_an_image) do
    SolrDocument.new(id: 'ab123fd9876',
                     blacklight_config.index.title_field => 'title')
  end

  context 'thumbnail' do
    it 'calls DefaultThumbnailJob to fetch a default feature image' do
      expect(Spotlight::DefaultThumbnailJob).to receive(:perform_later).with(subject)
      subject.save!
    end

    context '#set_default_thumbnail' do
      it 'has a default feature image' do
        allow(subject).to receive_messages(documents: [document])
        subject.set_default_thumbnail
        expect(subject.thumbnail).not_to be_nil
        expect(subject.thumbnail.image.path).to end_with 'default.jpg'
      end

      it 'uses a document with an image for the default feature image' do
        allow(subject).to receive_messages(documents: [document_without_an_image, document])
        subject.set_default_thumbnail
        expect(subject.thumbnail).not_to be_nil
        expect(subject.thumbnail.image.path).to end_with 'default.jpg'
      end

      context 'when full_image_field is nil' do
        before do
          allow(Spotlight::Engine.config).to receive_messages(full_image_field: nil)
        end
        it "doesn't query solr" do
          expect(subject).not_to receive(:documents)
          subject.set_default_thumbnail
          expect(subject.thumbnail).to be_nil
        end
      end
    end
  end

  describe 'for a search matching all items' do
    let(:query_params) { {} }

    it 'has items' do
      expect(subject.documents.size).to eq 55
    end

    it 'has images' do
      expect(subject.images.size).to eq(55)
      expect(subject.images.map(&:last)).to include 'https://stacks.stanford.edu/image/dq287tq6352/dq287tq6352_05_0001_thumb',
                                                    'https://stacks.stanford.edu/image/jp266yb7109/jp266yb7109_05_0001_thumb'
    end
  end

  describe 'default_scope' do
    let!(:page1) { FactoryGirl.create(:search, weight: 5, published: true) }
    let!(:page2) { FactoryGirl.create(:search, weight: 1, published: true) }
    let!(:page3) { FactoryGirl.create(:search, weight: 10, published: true) }
    it 'orders by weight' do
      expect(described_class.published.map(&:weight)).to eq [1, 5, 10]
    end
  end

  describe '#slug' do
    let(:search) { FactoryGirl.create(:search) }

    it 'gets a default slug' do
      expect(search.slug).not_to be_blank
    end

    it 'is updated when the title changes' do
      search.update(title: 'abc')
      expect(search.slug).to eq 'abc'
    end

    context 'with a custom slug' do
      let(:search) { FactoryGirl.create(:search, slug: 'xyz') }

      it 'gets a default slug' do
        expect(search.slug).to eq 'xyz'
      end
    end
  end

  describe '#search_params' do
    it 'maps the search to the appropriate facet values' do
      expect(subject.search_params.to_hash).to include 'fq' => array_including('{!raw f=genre_sim}map')
    end

    context 'with filter_resources_by_exhibit configured' do
      before do
        allow(Spotlight::Engine.config).to receive(:filter_resources_by_exhibit).and_return(true)
      end

      it 'includes the exhibit context' do
        expect(subject.search_params.to_hash).to include 'fq' => array_including("spotlight_exhibit_slug_#{exhibit.slug}_bsi:true")
      end
    end
  end

  describe '#repository' do
    let(:search) { FactoryGirl.create(:search) }
    before do
      allow(search).to receive(:blacklight_config).and_return blacklight_config
    end
    it 'returns an exhibit specific config' do
      expect(search.send(:repository).blacklight_config).to eql blacklight_config
    end
  end
end
