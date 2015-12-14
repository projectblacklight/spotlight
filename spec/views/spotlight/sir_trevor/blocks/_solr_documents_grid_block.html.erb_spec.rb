require 'spec_helper'

describe 'spotlight/sir_trevor/blocks/_solr_documents_grid_block.html.erb', type: :view do
  let(:p) { 'spotlight/sir_trevor/blocks/solr_documents_grid_block.html.erb' }
  let(:page) { double('Page') }
  let(:block) do
    SirTrevorRails::Blocks::SolrDocumentsGridBlock.new({ type: 'block', data: { title: 'Some title', text: 'Some text', 'text-align' => 'right' } }, page)
  end

  before do
    allow(block).to receive(:each_document).and_return([
      [{}, SolrDocument.new(id: 1)],
      [{}, SolrDocument.new(id: 2)],
      [{}, SolrDocument.new(id: 3)]
    ])
  end

  before do
    allow(view).to receive_messages(has_thumbnail?: true, render_thumbnail_tag: 'thumb')
  end

  it 'has a slideshow block' do
    render partial: p, locals: { solr_documents_grid_block: block }
    expect(rendered).to have_selector 'h3', text: 'Some title'
    expect(rendered).to have_content 'Some text'
    expect(rendered).to have_selector '.box', text: 'thumb', count: 3
    expect(rendered).to have_selector '.items-col.pull-left'
    expect(rendered).to have_selector '.text-col'
  end
end
