# frozen_string_literal: true

describe 'Metadata Administration', js: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit:) }

  before { login_as admin }

  describe 'Select/Deselect all checkbox' do
    it 'deselects all checkboxes when all are selected' do
      visit spotlight.edit_exhibit_metadata_configuration_path exhibit
      # No checkboxes should be unchecked
      expect(page).to have_no_css("tr td:nth-child(2) input[type='checkbox']:not(:checked)")
      within('tr th:nth-child(2)') do
        #click_button 'Deselect all'
        #click_input 'All'
        check('All', allow_label_click: true)
        # expect(page).to have_css('input', text: 'All', visible: true)
      end
      # No checkboxes should be checked
      expect(page).to have_no_css("tr td:nth-child(2) input[type='checkbox']:checked")
    end

    it 'selects all checkboxes when any are unselected' do
      visit spotlight.edit_exhibit_metadata_configuration_path exhibit
      # No checkboxes should be unchecked
      expect(page).to have_no_css("tr td:nth-child(2) input[type='checkbox']:not(:checked)")
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
      expect(page).to have_no_css("tr td:nth-child(2) input[type='checkbox']:not(:checked)")
    end
  end
end
