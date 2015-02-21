require "spec_helper"

describe "Sort Fields Administration", :type => :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as exhibit_curator }

  describe "edit" do
    it "should display the sort fields edit screen" do
      visit spotlight.exhibit_edit_sort_fields_path(exhibit)
      expect(page).to have_css("h1 small", text: "Sort fields")
    end

    it "should update options" do
      visit spotlight.exhibit_edit_sort_fields_path(exhibit)

      # #field_labeled doesn't appear to work for disabled inputs
      expect(page).to have_css("input[name='blacklight_configuration[sort_fields][relevance][enable]'][disabled='disabled']")
      expect(page).to have_css("#nested-sort-fields .dd-item:nth-child(5) h3", text: "Identifier")

      uncheck "blacklight_configuration_sort_fields_title_enabled"
      uncheck "blacklight_configuration_sort_fields_identifier_enabled"

      find("#blacklight_configuration_sort_fields_type_weight").set("100")

      click_button "Save changes"
      
      within "#sidebar" do
        click_link "Sort fields"
      end

      expect(page).to have_css("input[name='blacklight_configuration[sort_fields][relevance][enable]'][disabled='disabled']")
      expect(find("#blacklight_configuration_sort_fields_type_enabled")).to be_checked
      expect(find("#blacklight_configuration_sort_fields_date_enabled")).to be_checked
      expect(find("#blacklight_configuration_sort_fields_title_enabled")).to_not be_checked
      expect(find("#blacklight_configuration_sort_fields_identifier_enabled")).to_not be_checked

      # Type is now sorted last
      expect(page).to have_css("#nested-sort-fields .dd-item:nth-child(5) h3", text: "Type")
    end
  end
end
