require 'spec_helper'

module Spotlight
  describe "spotlight/pages/index" do
    let(:exhibit) { stub_model(Exhibit) }
    before do
      view.stub(:page_model).and_return("feature_page")
      view.stub(:update_all_pages_exhibits_path).and_return("/update")
      view.stub(:new_spotlight_page_path_for).and_return("/")
      assign(:exhibit, exhibit)
      assign(:pages, [
        stub_model(FeaturePage,
          :title => "Title",
          :content => "MyText",
          :exhibit => exhibit
        ),
        stub_model(FeaturePage,
          :title => "Title",
          :content => "MyText",
          :exhibit => exhibit
        )
      ])
    end

    it "renders a list of pages" do
      render
      # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "h3", :text => "Title".to_s, :count => 2
    end
  end
end
