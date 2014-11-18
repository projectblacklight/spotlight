require 'spec_helper'

describe 'sir-trevor/blocks/_item_features_block.html.erb', :type => :view do
  let(:block) do
    double()
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

  it "should have a slideshow" do
    render
    expect(rendered).to have_selector '.slideshow'
    expect(rendered).to have_selector '.item', text: 'thumb', count: 3
    expect(rendered).to have_selector '.slideshow-indicators'
    expect(rendered).to have_selector '.slideshow-indicators .list-group-item', count: 3 
  end
  it 'should truncated long titles (and keep the full title as the title attribute)' do
    caption = 'abcdef ' * 20
    allow(view).to receive_messages(multi_up_item_grid_caption: caption)
    render
    expect(rendered).to have_selector '.slideshow-indicators .list-group-item', count: 3, text: /a\.\.\.$/
    expect(rendered).to have_selector ".slideshow-indicators .list-group-item a[title='#{caption}']"
  end
end