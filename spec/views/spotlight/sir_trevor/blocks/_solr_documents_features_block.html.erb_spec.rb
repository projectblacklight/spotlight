# frozen_string_literal: true

RSpec.describe 'spotlight/sir_trevor/blocks/_solr_documents_features_block.html.erb', type: :view do
  let(:p) { 'spotlight/sir_trevor/blocks/solr_documents_features_block' }
  let(:block) do
    SirTrevorRails::Blocks::SolrDocumentsFeaturesBlock.new({ type: 'block', data: { 'show-primary-caption' => true, 'primary-caption-field' => 'x' } }, page)
  end

  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.index.title_field = 'full_title_tesim'
    end
  end

  before do
    doc1 = [{ full_image_url: 'http://example.com', decorative: 'on' }, SolrDocument.new(id: 1, x: 'a' * 100)]
    doc2 = [{ full_image_url: 'http://example.com' }, SolrDocument.new(id: 2, full_title_tesim: 'full_title')]
    doc3 = [{ full_image_url: 'http://example.com', alt_text: 'custom alt text' }, SolrDocument.new(id: 3)]
    allow(block).to receive(:each_document).and_return([doc1, doc2, doc3])
    allow(block).to receive_messages(documents?: true)
    allow(view).to receive_messages(solr_documents_features_block: block)
    allow(view).to receive_messages(blacklight_config:)
    allow(view).to receive_messages(document_link_params: {})
    allow_any_instance_of(Blacklight::ThumbnailPresenter).to receive_messages(exists?: true, thumbnail_tag: 'thumb')
  end

  it 'has a slideshow block' do
    render partial: p, locals: { item_carousel_block: block }
    expect(rendered).to have_selector '.item-features'
    expect(rendered).to have_selector '.carousel-item img', count: 3
    expect(rendered).to have_selector '.carousel-indicators'
    expect(rendered).to have_selector '.carousel-indicators li', count: 3
  end

  it 'truncates long titles' do
    render partial: p, locals: { item_carousel_block: block }
    expect(rendered).to have_selector '.item-features'
    expect(rendered).to have_selector '.carousel-item img', count: 3
    expect(rendered).to have_selector '.carousel-indicators'
    expect(rendered).to have_selector '.carousel-indicators li', count: 3
    expect(rendered).to have_selector '.carousel-indicators li', text: ('a' * 92) + '...'
  end

  describe 'without a primary caption' do
    let(:block) do
      SirTrevorRails::Blocks::SolrDocumentsFeaturesBlock.new({ type: 'block', data: { 'show-primary-caption' => false } }, page)
    end

    it 'falls back to the regular document title for the caption' do
      render partial: p, locals: { item_carousel_block: block }
      expect(rendered).to have_selector '.item-features'
      expect(rendered).to have_selector '.carousel-indicators li', text: 'full_title'
    end
  end

  it 'uses the correct alt text' do
    render partial: p, locals: { item_carousel_block: block }
    expect(rendered).to have_selector '.carousel-item img[alt=""]'
    expect(rendered).to have_selector '.carousel-item img[alt="full_title"]'
    expect(rendered).to have_selector '.carousel-item img[alt="custom alt text"]'
  end
end
