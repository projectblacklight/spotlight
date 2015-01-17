require 'spec_helper'

describe Spotlight::TitleHelper, :type => :helper do
  before do
    allow(helper).to receive_messages(application_name: "Application")
  end

  describe "#page_title" do
    it "should set the @page_title ivar" do
      helper.page_title("Section", "Title")
      title = helper.instance_variable_get(:@page_title)
      expect(title).to eq "Section - Title | Application"
    end

    it "should render the section title and the page title" do
      title = helper.page_title("Section", "Title")
      expect(title).to have_selector "h1", text: "Section"
      expect(title).to have_selector "h1 small", text: "Title"
      
    end
  end

  describe "#set_html_page_title" do
    it "should assign the @page_title ivar" do
      allow(helper).to receive_messages(application_name: "B")
      helper.set_html_page_title "A"
      title = helper.instance_variable_get(:@page_title)
      expect(title).to eq "A | B"
    end
    it 'should strip out any HTML tags' do
      allow(helper).to receive_messages(application_name: "B")
      expect(helper.set_html_page_title("<b>text</b> should not include HTML")).to eq "text should not include HTML | B"
    end
  end

  describe "#curation_page_title" do
    it "should render a page title in the curation section" do
      title = helper.curation_page_title "Some title"
      expect(title).to have_selector "h1", text: "Curation"
      expect(title).to have_selector "h1 small", text: "Some title"
    end
  end

  describe "#administration_page_title" do
    it "should render a page title in the administration section" do
      title = helper.administration_page_title "Some title"
      expect(title).to have_selector "h1", text: "Administration"
      expect(title).to have_selector "h1 small", text: "Some title"
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
