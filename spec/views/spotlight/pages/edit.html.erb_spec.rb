require 'spec_helper'

module Spotlight
  describe "spotlight/pages/edit" do
    let(:exhibit) { stub_model(Exhibit) } 
    let(:page) { stub_model(FeaturePage, exhibit: exhibit) }
    before do
      assign(:page, page)
    end

    it "renders the edit page form" do
      render

      # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "form[action=?][method=?]", spotlight.feature_page_path(page), "post" do
        assert_select "input#feature_page_title[name=?]", "feature_page[title]"
        assert_select "textarea#feature_page_content[name=?]", "feature_page[content]"
      end
    end
  end
end
