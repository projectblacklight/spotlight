require 'spec_helper'

describe "spotlight/catalog/_document_slideshow.html.erb" do
  let(:blacklight_config) { Blacklight::Configuration.new }

  let(:document) { stub_model(::SolrDocument) }

  before do
    view.stub(blacklight_config: blacklight_config)
    view.stub(documents: [document])
  end

  it "should have a edit tag form" do
    render
    expect(rendered).to have_selector '#slideshow-modal'
    expect(rendered).to have_selector '[data-slide="prev"]'
    expect(rendered).to have_selector '[data-slide="next"]'
    expect(rendered).to have_selector '[data-state="play"]'
    expect(rendered).to have_selector '[data-state="pause"]'
    expect(rendered).to have_selector '[data-velocity][value="2000"]'
    expect(rendered).to have_selector '[data-velocity][value="3000"]'
    expect(rendered).to have_selector '[data-velocity][value="6000"]'
    expect(rendered).to have_selector '[data-slide-to="0"][data-toggle="modal"][data-target="#slideshow-modal"]'
  end
end
