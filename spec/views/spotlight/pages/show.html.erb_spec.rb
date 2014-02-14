require 'spec_helper'

module Spotlight
  describe "spotlight/pages/show" do
    let(:exhibit) { stub_model(Exhibit) }
    before(:each) do
      view.send(:extend, Spotlight::CrudLinkHelpers)
      @page = assign(:page, stub_model(FeaturePage,
        :exhibit => exhibit,
        :title => "Title",
        :content => "{}"
      ))
      stub_template "spotlight/pages/_sidebar.html.erb" => "Sidebar"
      
    end

    it "renders attributes in <p>" do
      render
      rendered.should match(/Title/)
    end

    describe "admin user" do

      let(:user) { FactoryGirl.create(:exhibit_curator) }
      before {sign_in user }

      it "should have an edit link" do
        render
        expect(rendered).to have_link "Edit", href: spotlight.polymorphic_path([:edit, @page])
      end
    end

    describe "anonymous user" do

      it "should not give them an edit link" do
        render
        expect(rendered).to_not have_link "Edit"
      end
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
