require 'spec_helper'

module Spotlight
  describe "shared/_exhibit_masthead" do
    let(:current_exhibit) { double(title: "Some title", subtitle: "Subtitle") }
    let(:current_exhibit_without_subtitle) { double(title: "Some title", subtitle: nil) }
  
    it "should display the title and subtitle" do
      view.stub(current_exhibit: current_exhibit)
      render
      expect(rendered).to have_selector('.site-title', text: "Some title")
      expect(rendered).to have_selector('.site-title small', text: "Subtitle")
    end

    it "should display just the title" do
      view.stub(current_exhibit: current_exhibit_without_subtitle)
      render
      expect(rendered).to have_selector('.site-title', text: "Some title")
      expect(rendered).to_not have_selector('.site-title small')
    end
  end
end