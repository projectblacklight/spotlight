# frozen_string_literal: true

describe 'spotlight/sir_trevor/blocks/_solr_documents_carousel_block.html.erb', type: :view do
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
                                                         [{}, SolrDocument.new(id: 1)],
                                                         [{}, SolrDocument.new(id: 2)],
                                                         [{}, SolrDocument.new(id: 3)]
                                                       ])
    allow(block).to receive_messages(documents?: true)
    allow(view).to receive_messages(solr_documents_carousel_block: block)
    allow(view).to receive_messages(document_presenter: stub_presenter, blacklight_config: Blacklight::Configuration.new)
  end

  it 'has a slideshow block' do
    render partial: p, locals: { item_carousel_block: block }
    expect(rendered).to have_selector '.carousel-block'
    expect(rendered).to have_selector '.carousel-control-prev.left'
    expect(rendered).to have_selector '.carousel-control-next.right'
    expect(rendered).to have_selector '.carousel-item', text: 'thumb', count: 3
    expect(rendered).to have_selector '.carousel-indicators'
    expect(rendered).to have_selector '.carousel-indicators li', count: 3
  end
end
