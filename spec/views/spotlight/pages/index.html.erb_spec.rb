require 'spec_helper'

module Spotlight
  describe "spotlight/pages/index" do
    before do
      assign(:exhibit, stub_model(Exhibit))
      assign(:pages, [
        stub_model(Page,
          :title => "Title",
          :content => "MyText"
        ),
        stub_model(Page,
          :title => "Title",
          :content => "MyText"
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
