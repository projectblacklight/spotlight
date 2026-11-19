# frozen_string_literal: true

RSpec.describe 'spotlight/sir_trevor/blocks/_link_to_search_block.html.erb', type: :view do
  let(:partial) { 'spotlight/sir_trevor/blocks/link_to_search_block' }
  let(:page) { instance_double(Spotlight::FeaturePage, display_sidebar?: true) }
  let(:search) { FactoryBot.create(:search, query_params: { a: 1 }) }
  let(:data) { {} }
  let(:block) do
    assign(:page, page)
    SirTrevorRails::Blocks::LinkToSearchBlock.new({ type: 'block', data: }, page)
  end

  before do
    view.extend(Spotlight::ApplicationHelper)
    allow(block).to receive(:searches).and_return([search])
    allow(search).to receive(:count).and_return(5)
  end

  it 'links to the search' do
    render partial:, locals: { link_to_search_block: block }
    expect(rendered).to have_link search.title, href: spotlight.search_exhibit_catalog_path(search.exhibit, a: 1)
    expect(rendered).to have_no_css '.item-count'
  end

  context 'when configured to display item counts' do
    let(:data) { { 'display-item-counts' => 'true' } }

    it 'shows the number of items in the search' do
      render partial:, locals: { link_to_search_block: block }
      expect(rendered).to have_css '.item-count', text: '5 items'
    end
  end

  context 'with more than five browse categories' do
    before do
      allow(block).to receive(:searches).and_return([search] * 6)
    end

    it 'uses the five-up layout so the tiles are sized and wrap' do
      render partial:, locals: { link_to_search_block: block }
      expect(rendered).to have_css '.browse-categories.categories-5'
      expect(rendered).to have_css '.box', count: 6
    end
  end
end
