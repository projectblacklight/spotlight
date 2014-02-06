require 'spec_helper'

describe "spotlight/items/edit.html.erb" do
  before do
    assign(:exhibit, stub_model(Spotlight::Exhibit))
    assign(:document, stub_model(::SolrDocument))
  end

  before do
    view.stub(:document_show_html_title)
    view.stub(:exhibit_item_path => '/foo')
  end
  it "renders a link to the edit page" do
    render
    expect(rendered).to have_link "Turn off."
  end
end



