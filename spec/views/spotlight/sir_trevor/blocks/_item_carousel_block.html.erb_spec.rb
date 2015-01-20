require 'spec_helper'

describe 'spotlight/sir_trevor/blocks/_item_carousel_block.html.erb', :type => :view do

  let(:p) { "spotlight/sir_trevor/blocks/item_carousel_block.html.erb" }
  let(:block) do
    double(
      with_solr_helper: nil, 
      :'item-grid-display-caption' => false, 
      :'auto-play-images-interval' => false,
      :'auto-play-images' => false,
      max_height:0,
      primary_caption?:true,
      secondary_caption?:false,
      block_objects:
    [OpenStruct.new(id: '1', solr_document: ::SolrDocument.new(id: 1)),
      OpenStruct.new(id: '2', solr_document: ::SolrDocument.new(id: 2)),
      OpenStruct.new(id: '3', solr_document: ::SolrDocument.new(id: 3))]
      )
    end

  before do
    allow(view).to receive_messages(multi_up_item_grid_caption: 'caption')
    allow(view).to receive_messages(has_thumbnail?: true, render_thumbnail_tag: 'thumb')
  end

  it "should have a slideshow block" do
    render partial: p, locals: { item_carousel_block: block}
    expect(rendered).to have_selector '.slideshow-block'
    expect(rendered).to have_selector '.carousel-control.left'
    expect(rendered).to have_selector '.carousel-control.right'
    expect(rendered).to have_selector '.item', text: 'thumb', count: 3
    expect(rendered).to have_selector '.slideshow-indicators'
    expect(rendered).to have_selector '.slideshow-indicators li', count: 3
  end
end