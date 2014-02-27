require 'spec_helper'

describe 'sir-trevor/blocks/_item_features_block.html.erb' do
  let(:block) do
    double()
  end

  let(:docs) do
    [::SolrDocument.new(id: 1), 
     ::SolrDocument.new(id: 2),
     ::SolrDocument.new(id: 3)]
  end

  before do
    view.stub(block: block)
    view.stub(item_grid_block_ids: [1,2,3])
    view.stub(get_solr_response_for_field_values: [nil, docs])
    view.stub(multi_up_item_grid_caption: 'caption')
    view.stub(has_thumbnail?: true, render_thumbnail_tag: 'thumb')
  end

  it "should have a slideshow" do
    render
    expect(rendered).to have_selector '.slideshow'
    expect(rendered).to have_selector '.item', text: 'thumb', count: 3
    expect(rendered).to have_selector '.slideshow-indicators'
    expect(rendered).to have_selector '.slideshow-indicators .list-group-item', count: 3 
  end
end