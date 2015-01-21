require "spec_helper"

describe "Uploading a non-repository item", :type => :feature do
  let!(:exhibit) { FactoryGirl.create(:exhibit) }
  let!(:custom_field) { FactoryGirl.create(:custom_field, exhibit: exhibit) }
  let!(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as exhibit_curator }

  describe "upload" do
    it "should display the single item upload form" do
      visit spotlight.new_exhibit_resources_upload_path(exhibit)
      expect(page).to have_css("h1", text: /Curation/)
      expect(page).to have_css "h1 small", text: "Add non-repository items"
      within("form#new_resources_upload") do
        expect(page).to have_css('#resources_upload_url[type="file"]')
        expect(page).to have_css('.help-block', text: 'Valid file types: jpg jpeg png')
        expect(page).to have_css('#resources_upload_data_full_title_tesim[type="text"]')
        expect(page).to have_css('textarea#resources_upload_data_spotlight_upload_description_tesim')
        expect(page).to have_css('#resources_upload_data_spotlight_upload_attribution_tesim[type="text"]')
        expect(page).to have_css('#resources_upload_data_spotlight_upload_date_tesim[type="text"]')
        expect(page).to have_css("#resources_upload_data_#{custom_field.field}[type='text']")
      end
    end
    it "should display the multi-item CSV upload form" do
      visit spotlight.new_exhibit_resources_upload_path(exhibit)
      expect(page).to have_css("h1", text: /Curation/)
      expect(page).to have_css "h1 small", text: "Add non-repository items"
      within("form#new_resources_csv_upload") do
        expect(page).to have_css('#resources_csv_upload_url[type="file"]')
        expect(page).to have_css('.help-block a', text: 'Download template')
      end
    end
  end
end
