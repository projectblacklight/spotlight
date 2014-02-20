require 'spec_helper'

module Spotlight
  describe "spotlight/pages/show" do
    let(:exhibit) { stub_model(Exhibit) }
    before(:each) do
      view.stub(:current_exhibit).and_return(exhibit)
      @page = assign(:page, stub_model(FeaturePage,
        :exhibit => exhibit,
        :title => "Title",
        :content => "{}"
      ))
      stub_template "spotlight/pages/_sidebar.html.erb" => "Sidebar"
      
    end

    it "should render the title as a heading" do
      render
      expect(rendered).to have_css(".page-title", text: @page.title)
    end
    it "should not render an empty heading" do
      @page.stub(title: nil)
      render
      expect(rendered).to_not have_css(".page-title")
    end

    it "renders attributes in <p>" do
      render
      rendered.should match(/Title/)
    end

    it "should render the sidebar" do
      @page.display_sidebar = true
      render
      expect(rendered).to match("Sidebar")
    end

    it "should not render the sidebar if the page has it disabled" do
      @page.stub(display_sidebar: false)
      render
      expect(rendered).to_not match("Sidebar")
    end
  end
end
