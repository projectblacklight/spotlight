# frozen_string_literal: true

RSpec.describe 'spotlight/sir_trevor/blocks/_solr_documents_grid_block', type: :view do
  let(:p) { 'spotlight/sir_trevor/blocks/solr_documents_grid_block' }
  let(:page) { double('Page') }
  let(:block) do
    SirTrevorRails::Blocks::SolrDocumentsGridBlock.new({ type: 'block', data: { title: 'Some title', text: 'Some text', 'text-align' => 'right' } }, page)
  end
  let(:blacklight_config) do
    Blacklight::Configuration.new
  end

  let(:stub_presenter) do
    instance_double(Blacklight::DocumentPresenter, heading: 'blah', thumbnail: thumbnail_presenter)
  end

  let(:thumbnail_presenter) { instance_double(Blacklight::ThumbnailPresenter, exists?: true, thumbnail_tag: 'thumb') }

  before do
    allow(block).to receive(:each_document).and_return([
                                                         [{ thumbnail_image_url: 'http://example.com', decorative: 'on' }, SolrDocument.new(id: 1)],
                                                         [{ thumbnail_image_url: 'http://example.com', alt_text: 'custom alt text' }, SolrDocument.new(id: 2)],
                                                         [{ thumbnail_image_url: 'http://example.com' }, SolrDocument.new(id: 3)]
                                                       ])
    allow(view).to receive_messages(
      blacklight_config:,
      document_presenter: stub_presenter,
      document_link_params: {}
    )
    render partial: p, locals: { solr_documents_grid_block: block }
  end

  it 'has a slideshow block' do
    expect(rendered).to have_selector 'h3', text: 'Some title'
    expect(rendered).to have_content 'Some text'
    expect(rendered).to have_selector '.box img', count: 3
    expect(rendered).to have_selector '.items-col'
    expect(rendered).to have_selector '.text-col'
  end

  it 'uses the correct alt text' do
    expect(rendered).to have_selector '.item-0 img[alt=""]'
    expect(rendered).to have_selector '.item-1 img[alt="custom alt text"]'
    expect(rendered).to have_selector '.item-2 img[alt="blah"]'
  end
end
