require 'spec_helper'

describe Spotlight::AdminTitleHelper do
  before do
    helper.stub(application_name: "Application")
  end

  describe "#page_title" do
    it "should set the @page_title ivar" do
      helper.page_title("Section", "Title")
      title = helper.instance_variable_get(:@page_title)
      expect(title).to eq "Section - Title  --  Application"
    end

    it "should render the section title and the page title" do
      title = helper.page_title("Section", "Title")
      expect(title).to have_selector "h1", text: "Section"
      expect(title).to have_selector "h2", text: "Title"
      
    end
  end

  describe "#curation_page_title" do
    it "should render a page title in the curation section" do
      title = helper.curation_page_title "Some title"
      expect(title).to have_selector "h1", text: "Curation"
      expect(title).to have_selector "h2", text: "Some title"
    end
  end

  describe "#administration_page_title" do
    it "should render a page title in the administration section" do
      title = helper.administration_page_title "Some title"
      expect(title).to have_selector "h1", text: "Administration"
      expect(title).to have_selector "h2", text: "Some title"
    end
  end

  describe "#header_with_count" do
    it "should merge the title with a count label" do
      val = helper.header_with_count "some title", 5
      expect(val).to match /some title /
      expect(val).to have_selector "span.label", text: 5
    end
  end

end
