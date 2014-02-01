require 'spec_helper'

module Spotlight
  describe "spotlight/pages/show" do
    let(:exhibit) { stub_model(Exhibit) }
    before(:each) do
      @page = assign(:page, stub_model(FeaturePage,
        :exhibit => exhibit,
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