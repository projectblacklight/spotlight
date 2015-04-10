require 'spec_helper'

feature 'Metadata Administration', js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:admin) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
  before { login_as admin }
  describe 'Select/Deselect all button' do
    it 'deselects all checkboxes when all are selected' do
      visit spotlight.edit_exhibit_metadata_configuration_path exhibit
      # No checkboxes should be unchecked
      expect(page).not_to have_css("tr td:nth-child(2) input[type='checkbox']:not(:checked)")
      within('tr th:nth-child(2)') do
        click_button 'Deselect all'
        expect(page).to have_css('button', text: 'Select all', visible: true)
      end
      # No checkboxes should be checked
      expect(page).not_to have_css("tr td:nth-child(2) input[type='checkbox']:checked")
    end
    it 'selects all checkboxes when any are unselected' do
      visit spotlight.edit_exhibit_metadata_configuration_path exhibit
      # No checkboxes should be unchecked
      expect(page).not_to have_css("tr td:nth-child(2) input[type='checkbox']:not(:checked)")
      first_button_area = find('tr th:nth-child(2)')
      within first_button_area do
        expect(page).to have_css('button', text: 'Deselect all')
      end
      # Uncheck first checkbox
      find("tr:first-child td:nth-child(2) input[type='checkbox']").set(false)
      # A checkbox should be checked
      expect(page).to have_css("tr td:nth-child(2) input[type='checkbox']:checked")
      within first_button_area do
        click_button 'Select all'
      end
      # No checkboxes should be unchecked
      expect(page).not_to have_css("tr td:nth-child(2) input[type='checkbox']:not(:checked)")
    end
  end
end
