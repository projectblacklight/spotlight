require 'spec_helper'

describe 'spotlight/sir_trevor/blocks/_solr_documents_features_block.html.erb', type: :view do
  let(:p) { 'spotlight/sir_trevor/blocks/solr_documents_features_block.html.erb' }
  let(:block) do
    SirTrevorRails::Blocks::SolrDocumentsFeaturesBlock.new({ type: 'block', data: { 'show-primary-caption' => true, 'primary-caption-field' => 'x' } }, page)
  end

  before do
    doc1 = [{}, SolrDocument.new(id: 1, x: 'a' * 100)]
    doc2 = [{}, SolrDocument.new(id: 2)]
    doc3 = [{}, SolrDocument.new(id: 3)]
    allow(block).to receive(:each_document).and_return([doc1, doc2, doc3])
    allow(block).to receive_messages(documents?: true)
    allow(view).to receive_messages(solr_documents_features_block: block)
    allow(view).to receive_messages(has_thumbnail?: true, render_thumbnail_tag: 'thumb', blacklight_config: Blacklight::Configuration.new)
  end

  it 'has a slideshow block' do
    render partial: p, locals: { item_carousel_block: block }
    expect(rendered).to have_selector '.item-features'
    expect(rendered).to have_selector '.item', text: 'thumb', count: 3
    expect(rendered).to have_selector '.carousel-indicators'
    expect(rendered).to have_selector '.carousel-indicators li', count: 3
  end

  it 'truncates long titles' do
    render partial: p, locals: { item_carousel_block: block }
    expect(rendered).to have_selector '.item-features'
    expect(rendered).to have_selector '.item', text: 'thumb', count: 3
    expect(rendered).to have_selector '.carousel-indicators'
    expect(rendered).to have_selector '.carousel-indicators li', count: 3
    expect(rendered).to have_selector '.carousel-indicators li', text: 'a' * 92 + '...'
  end
end
