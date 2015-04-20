require 'spec_helper'

describe Spotlight::Search, type: :model do
  let(:query_params) { { 'f' => { 'genre_sim' => ['map'] } } }
  subject { FactoryGirl.build(:search, query_params: query_params) }

  let(:blacklight_config) { ::CatalogController.blacklight_config }
  let(:document) do
    SolrDocument.new(id: 'dq287tq6352',
                     blacklight_config.index.title_field => 'title',
                     Spotlight::Engine.config.full_image_field => 'https://stacks.stanford.edu/image/dq287tq6352/dq287tq6352_05_0001_thumb')
  end
  let(:document_without_an_image) do
    SolrDocument.new(id: 'ab123fd9876',
                     blacklight_config.index.title_field => 'title')
  end

  it { is_expected.to be_a Spotlight::Catalog::AccessControlsEnforcement }

  it 'has a default feature image' do
    allow(subject).to receive_messages(documents: [document])
    subject.save!
    expect(subject.thumbnail).not_to be_nil
    expect(subject.thumbnail.image.path).to end_with 'dq287tq6352_05_0001_thumb.jpeg'
  end

  it 'uses a document with an image for the default feature image' do
    allow(subject).to receive_messages(documents: [document_without_an_image, document])
    subject.save!
    expect(subject.thumbnail).not_to be_nil
    expect(subject.thumbnail.image.path).to end_with 'dq287tq6352_05_0001_thumb.jpeg'
  end

  it 'has items' do
    expect(subject.count).to eq 55
  end

  it 'has images' do
    expect(subject.images.size).to eq(55)
    expect(subject.images.map(&:last)).to include 'https://stacks.stanford.edu/image/dq287tq6352/dq287tq6352_05_0001_thumb',
                                                  'https://stacks.stanford.edu/image/jp266yb7109/jp266yb7109_05_0001_thumb'
  end

  describe 'default_scope' do
    let!(:page1) { FactoryGirl.create(:search, weight: 5, on_landing_page: true) }
    let!(:page2) { FactoryGirl.create(:search, weight: 1, on_landing_page: true) }
    let!(:page3) { FactoryGirl.create(:search, weight: 10, on_landing_page: true) }
    it 'orders by weight' do
      expect(described_class.published.map(&:weight)).to eq [1, 5, 10]
    end
  end
end
