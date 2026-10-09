# frozen_string_literal: true

RSpec.describe 'spotlight/sir_trevor/blocks/_browse_block.html.erb', type: :view do
  let(:partial) { 'spotlight/sir_trevor/blocks/browse_block' }
  let(:page) { double('Page', display_sidebar?: true) }
  let(:search) { FactoryBot.create(:search) }
  let(:data) { {} }
  let(:block) do
    assign(:page, page)
    SirTrevorRails::Blocks::BrowseBlock.new({ type: 'block', data: }, page)
  end

  before do
    allow(block).to receive(:searches).and_return([search])
    allow(search).to receive(:count).and_return(5)
  end

  it 'links to the search' do
    render partial:, locals: { browse_block: block }
    expect(rendered).to have_link search.title, href: spotlight.exhibit_browse_path(search.exhibit, search)
    expect(rendered).to have_no_css '.item-count'
  end

  context 'when configured to display item counts' do
    let(:data) { { 'display-item-counts' => 'true' } }

    it 'shows the number of items in the search' do
      render partial:, locals: { browse_block: block }
      expect(rendered).to have_css '.item-count', text: '5 items'
    end
  end
end
