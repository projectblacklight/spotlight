require 'spec_helper'

describe 'sir-trevor/blocks/_item_carousel_block.html.erb', :type => :view do
  let(:block) do
    { 'item-grid-display-caption' => false }
  end

  let(:docs) do
    [::SolrDocument.new(id: 1),
     ::SolrDocument.new(id: 2),
     ::SolrDocument.new(id: 3)]
  end

  before do
    allow(view).to receive_messages(block: block)
    allow(view).to receive_messages(item_grid_block_ids: [1,2,3])
    allow(view).to receive_messages(get_solr_response_for_field_values: [nil, docs])
    allow(view).to receive_messages(multi_up_item_grid_caption: 'caption')
    allow(view).to receive_messages(has_thumbnail?: true, render_thumbnail_tag: 'thumb')
  end

  it "should have a slideshow block" do
    render
    expect(rendered).to have_selector '.slideshow-block'
    expect(rendered).to have_selector '.carousel-control.left'
    expect(rendered).to have_selector '.carousel-control.right'
    expect(rendered).to have_selector '.item', text: 'thumb', count: 3
    expect(rendered).to have_selector '.slideshow-indicators'
    expect(rendered).to have_selector '.slideshow-indicators li', count: 3
  end
end