require 'spec_helper'

module Spotlight
  describe "spotlight/pages/new" do
    before(:each) do
      assign(:page, stub_model(Page,
        :title => "MyString",
        :content => "MyText"
      ).as_new_record)
    end

    it "renders new page form" do
      render

      # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "form[action=?][method=?]", spotlight.pages_path, "post" do
        assert_select "input#page_title[name=?]", "page[title]"
        assert_select "textarea#page_content[name=?]", "page[content]"
      end
    end
  end
end