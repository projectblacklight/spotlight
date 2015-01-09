require "spec_helper"

describe "Uploading a non-repository item", :type => :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as exhibit_curator }

  describe "upload" do
    it "should display the single item upload form" do
      visit spotlight.new_exhibit_resources_upload_path(exhibit)
      expect(page).to have_css("h1", text: /Curation/)
      expect(page).to have_css "h1 small", text: "Add non-repository items"
      within("form.item-upload-form") do
        expect(page).to have_css('#resources_upload_url[type="file"]')
        expect(page).to have_css('.help-block', text: 'Valid file types: jpg jpeg png')
        expect(page).to have_css('#resources_upload_data_title[type="text"]')
      end
    end
  end
end
