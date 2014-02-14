require 'spec_helper'

describe "spotlight/pages/index.html.erb" do
  let(:pages) {[
      stub_model(Spotlight::FeaturePage,
        :title => "Title1",
        :content => "MyText",
        exhibit: exhibit
      ),
      stub_model(Spotlight::FeaturePage,
        :title => "Title2",
        :content => "MyText",
        exhibit: exhibit
      )
    ]}
  let(:exhibit) { stub_model(Spotlight::Exhibit) }
  before do
    view.send(:extend, Spotlight::CrudLinkHelpers)
    view.stub(:page_model).and_return(:feature_page)
    view.stub(:page_collection_name).and_return(:feature_pages)
    view.stub(:new_exhibit_feature_page_path).and_return("/exhibit/features")
    view.stub(:update_all_exhibit_feature_pages_path).and_return("/exhibit/features/update_all")
    assign(:exhibit, exhibit)
    view.stub(:current_exhibit).and_return(exhibit)
  end

  it "renders a list of pages" do
    assign(:pages, pages)
    exhibit.stub(:feature_pages).and_return pages
    render
    expect(rendered).to have_selector '.panel-title', text: 'Title1'
    expect(rendered).to have_selector '.panel-title', text: 'Title2'
  end

  describe "Without pages" do
    it "should disable the update button" do
      assign(:pages, [])
      render
      expect(rendered).to have_selector 'button[disabled]', text: "Save changes"
    end
  end
end
