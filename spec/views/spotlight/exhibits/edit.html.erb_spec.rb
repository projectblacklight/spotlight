require 'spec_helper'

module Spotlight
  describe "spotlight/exhibits/edit" do
    let(:exhibit) { FactoryGirl.create(:exhibit) } 
    before do
      assign(:exhibit, exhibit)
      view.stub(current_exhibit: exhibit)
    end

    it "renders the edit page form" do
      render

      expect(rendered).to have_selector "form[action=\"#{spotlight.exhibit_path(exhibit)}\"]"
      expect(rendered).to have_selector ".callout.callout-danger.row"
      expect(rendered).to have_content "This action is irreversable"
      expect(rendered).to have_link "Export", href: spotlight.import_exhibit_path(exhibit)

    end
  end
end

