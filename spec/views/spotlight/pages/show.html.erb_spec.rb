require 'spec_helper'

module Spotlight
  describe "spotlight/pages/show" do
    before(:each) do
      @page = assign(:page, stub_model(Page,
        :title => "Title",
        :content => "{}"
      ))
    end

    it "renders attributes in <p>" do
      render
      rendered.should match(/Title/)
    end
  end
end