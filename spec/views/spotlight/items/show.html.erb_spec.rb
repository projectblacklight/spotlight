require 'spec_helper'

describe "spotlight/items/show.html.erb" do
  before do
    assign(:exhibit, stub_model(Spotlight::Exhibit))
    assign(:document, stub_model(SolrDocument))
  end

  describe "when user can curate" do
    before do
      view.stub(:can? => true)
      view.stub(:edit_exhibit_item_path => '/foo')
    end
    it "renders a link to the edit page" do
      render
      expect(rendered).to have_link "Enter curation mode."
    end
  end

  describe "when user cannot curate" do
    it "doesn't render a link to the edit page" do
      render
      expect(rendered).not_to have_link "Enter curation mode."
    end
  end
end



