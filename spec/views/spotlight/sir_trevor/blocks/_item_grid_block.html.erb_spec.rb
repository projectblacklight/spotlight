require 'spec_helper'

describe 'spotlight/sir_trevor/blocks/_item_grid_block.html.erb', :type => :view do

  let(:p) { "spotlight/sir_trevor/blocks/item_grid_block.html.erb" }
  let(:block) do
    double(
      with_solr_helper: nil,
      title: "Some title",
      text: "Some text",
      text_align: "right",
      block_objects:
    [OpenStruct.new(id: '1', solr_document: ::SolrDocument.new(id: 1)),
      OpenStruct.new(id: '2', solr_document: ::SolrDocument.new(id: 2)),
      OpenStruct.new(id: '3', solr_document: ::SolrDocument.new(id: 3))]
      )
    end

  before do
    allow(view).to receive_messages(has_thumbnail?: true, render_thumbnail_tag: 'thumb')
  end

  it "should have a slideshow block" do
    render partial: p, locals: { item_grid_block: block}
    expect(rendered).to have_selector 'h3', text: 'Some title'
    expect(rendered).to have_content "Some text"
    expect(rendered).to have_selector '.box', text: 'thumb', count: 3
    expect(rendered).to have_selector '.items-col.pull-right'
  end
end