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
    exhibit.stub(:feature_pages).and_return pages
    view.stub(:page_model).and_return("feature_page")
    view.stub(:update_pages_path).and_return("/update")
    view.stub(:new_exhibit_feature_page_path).and_return("/exhibit/features")
    assign(:exhibit, exhibit)
  end

  it "renders a list of pages" do
    render
    expect(rendered).to have_selector '.panel-title', text: 'Title1'
    expect(rendered).to have_selector '.panel-title', text: 'Title2'
  end
end
