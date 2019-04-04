# frozen_string_literal: true

describe 'spotlight/sir_trevor/blocks/_link_to_search_block.html.erb', type: :view do
  let(:p) { 'spotlight/sir_trevor/blocks/link_to_search_block.html.erb' }
  let(:page) { double('Page', display_sidebar?: true) }
  let(:search) { FactoryBot.create(:search, query_params: { a: 1 }) }
  let(:block) do
    assign(:page, page)
    SirTrevorRails::Blocks::LinkToSearchBlock.new({ type: 'block', data: {} }, page)
  end

  before do
    allow(block).to receive(:searches).and_return([search])
  end

  it 'links to the search' do
    render partial: p, locals: { link_to_search_block: block }
    expect(rendered).to have_link search.title, href: spotlight.search_exhibit_catalog_path(search.exhibit, a: 1)
  end
end
