require 'spec_helper'

describe 'Edit in place', type: :feature, js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:admin)   { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
  before { login_as admin }
  describe 'Main navigation' do
    it 'should update the label' do
      skip("Passing locally but Travis is throwing intermittent errors") if ENV["CI"]
      visit spotlight.exhibit_dashboard_path(exhibit)

      within "#sidebar" do
        click_link "Appearance"
      end

      within("#nested-navigation") do
        expect(page).to     have_css("#appearance_main_navigations_1_label[type='hidden']", visible: false)
        expect(page).not_to have_css("#appearance_main_navigations_1_label[type='text']")
        click_link("Curated Features")
        expect(page).not_to have_css("#appearance_main_navigations_1_label[type='hidden']")
        expect(page).to     have_css("#appearance_main_navigations_1_label[type='text']")
        fill_in "appearance_main_navigations_1_label", with: "My Page Label"
      end

      click_button "Save changes"

      expect(page).to have_content("The appearance was successfully updated.")

      within("#nested-navigation") do
        expect(page).to have_css('h3', text: "My Page Label")
      end
    end
  end
  describe 'Sort fields' do
    it 'should update the label' do
      skip("Passing locally but Travis is throwing intermittent errors") if ENV["CI"]
      visit spotlight.exhibit_edit_sort_fields_path(exhibit)

      within "#sidebar" do
        click_link "Sort fields"
      end

      within("#nested-sort-fields") do
        expect(page).to     have_css("#blacklight_configuration_sort_fields_title_label[type='hidden']", visible: false)
        expect(page).not_to have_css("#blacklight_configuration_sort_fields_title_label[type='text']")
        click_link("Title")
        expect(page).not_to have_css("#blacklight_configuration_sort_fields_title_label[type='hidden']")
        expect(page).to     have_css("#blacklight_configuration_sort_fields_title_label[type='text']")
        fill_in "blacklight_configuration_sort_fields_title_label", with: "My Title Label"
      end

      click_button "Save changes"

      expect(page).to have_content("The exhibit was successfully updated.")

      within("#nested-sort-fields") do
        expect(page).to have_css('h3', text: "My Title Label")
      end
    end
  end
end
