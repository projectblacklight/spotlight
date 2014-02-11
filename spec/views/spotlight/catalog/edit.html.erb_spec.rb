require 'spec_helper'

describe "spotlight/catalog/edit.html.erb" do
  let(:blacklight_config) { Blacklight::Configuration.new }

  let(:document) { stub_model(::SolrDocument) }

  before do
    view.stub(blacklight_config: blacklight_config)
    view.stub(current_exhibit: stub_model(Spotlight::Exhibit))
    assign(:document, document)
  end

  before do
    view.stub(current_page?: true)
    view.stub(:document_show_html_title)
    view.stub(:edit_exhibit_catalog_path)
  end
  it "renders a link to the edit page" do
    blacklight_config.view.edit.partials = []
    render
    expect(rendered).to have_link "Turn off."
  end
end



