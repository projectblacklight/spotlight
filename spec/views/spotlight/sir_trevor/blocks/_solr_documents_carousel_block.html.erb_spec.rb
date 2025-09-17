# frozen_string_literal: true

RSpec.describe 'spotlight/sir_trevor/blocks/_solr_documents_carousel_block.html.erb', type: :view do
  let(:p) { 'spotlight/sir_trevor/blocks/solr_documents_carousel_block' }
  let(:block) do
    SirTrevorRails::Blocks::SolrDocumentsCarouselBlock.new({ type: 'block', data: {} }, page)
  end
  let(:stub_presenter) do
    instance_double(Blacklight::DocumentPresenter, heading: 'blah', thumbnail: thumbnail_presenter)
  end

  let(:thumbnail_presenter) { instance_double(Blacklight::ThumbnailPresenter, exists?: true, thumbnail_tag: 'thumb') }

  before do
    allow(block).to receive(:each_document).and_return([
                                                         [{ full_image_url: 'http://example.com', decorative: 'on' }, SolrDocument.new(id: 1)],
                                                         [{ full_image_url: 'http://example.com', alt_text: 'custom alt text' }, SolrDocument.new(id: 2)],
                                                         [{ full_image_url: 'http://example.com' }, SolrDocument.new(id: 3)]
                                                       ])
    allow(block).to receive_messages(documents?: true)
    allow(view).to receive_messages(solr_documents_carousel_block: block)
    allow(view).to receive_messages(document_presenter: stub_presenter, blacklight_config: Blacklight::Configuration.new, document_link_params: {})
    render partial: p, locals: { item_carousel_block: block }
  end

  it 'has a slideshow block' do
    expect(rendered).to have_selector '.carousel-block'
    expect(rendered).to have_selector '.carousel-control-prev.left'
    expect(rendered).to have_selector '.carousel-control-next.right'
    expect(rendered).to have_selector '.carousel-item img', count: 3
    expect(rendered).to have_selector '.carousel-indicators'
    expect(rendered).to have_selector '.carousel-indicators li', count: 3
  end

  it 'uses the correct alt text' do
    expect(rendered).to have_selector '.carousel-item img[alt=""]'
    expect(rendered).to have_selector '.carousel-item img[alt="custom alt text"]'
    expect(rendered).to have_selector '.carousel-item img[alt="blah"]'
  end

  it 'has correct data atttributes that will be used by aria-describedby' do
    expect(rendered).to have_selector '.carousel-item[data-id="1"][data-prev-id="carousel-caption-3"][data-next-id="carousel-caption-2"]'
    expect(rendered).to have_selector '.carousel-item[data-id="2"][data-prev-id="carousel-caption-1"][data-next-id="carousel-caption-3"]'
    expect(rendered).to have_selector '.carousel-item[data-id="3"][data-prev-id="carousel-caption-2"][data-next-id="carousel-caption-1"]'
  end
end
