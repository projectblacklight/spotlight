require 'spec_helper'

describe 'spotlight/sir_trevor/blocks/_browse_block.html.erb', type: :view do
  let(:p) { 'spotlight/sir_trevor/blocks/browse_block.html.erb' }
  let(:page) { double('Page', display_sidebar?: true) }
  let(:search) { FactoryGirl.create(:search) }
  let(:block) do
    assign(:page, page)
    SirTrevorRails::Blocks::BrowseBlock.new({ type: 'block', data: {} }, page)
  end

  before do
    allow(block).to receive(:searches).and_return([search])
  end

  it 'links to the search' do
    render partial: p, locals: { browse_block: block }
    expect(rendered).to have_link search.title, href: spotlight.exhibit_browse_path(search.exhibit, search)
  end
end
