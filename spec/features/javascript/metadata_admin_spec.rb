# frozen_string_literal: true

describe 'Metadata Administration', js: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit:) }

  before { login_as admin }

  describe 'Select/Deselect all checkbox' do
    it 'deselects all checkboxes when all are selected' do
      visit spotlight.edit_exhibit_metadata_configuration_path exhibit

      # All checkboxes in the item details column should checked
      expect(page).to have_no_css("tr td:nth-child(2) input[type='checkbox']:not(:checked)")
      # In the scope of the th element which contains the checkbox
      within('tr th:nth-child(2)') do
        find("input[type='checkbox']").set(false)
      end
      # After unchecking the all checkbox, all checkboxes in the item details column should be unchecked
      expect(page).to have_no_css("tr td:nth-child(2) input[type='checkbox']:checked")
    end

    it 'selects all checkboxes when any are unselected' do
      visit spotlight.edit_exhibit_metadata_configuration_path exhibit

      # No checkboxes should be unchecked
      expect(page).to have_no_css("tr td:nth-child(2) input[type='checkbox']:not(:checked)")
      # Find the "All" checkbox in the th field for the item details column
      first_checkbox_area = find('tr th:nth-child(2)')
      within first_checkbox_area do
        expect(page).to have_css("input[type='checkbox']")
        expect(page).to have_css('label', text: 'All')
      end
      # Uncheck first metadata field checkbox in the item details column
      find("tr:first-child td:nth-child(2) input[type='checkbox']").set(false)
      # Unchecking the first metadata checkbox should not uncheck other metadata field checkboxes
      expect(page).to have_css("tr td:nth-child(2) input[type='checkbox']:checked")
      within first_checkbox_area do
        # Unchecking one of the checkboxes should also uncheck "All"
        expect(page).to have_css("input[type='checkbox']:not(:checked)")
        # Check the "All" checkbox for the item details column
        find("input[type='checkbox']").set(true)
      end
      # After clicking "All", all checkboxes should be checked
      expect(page).to have_no_css("tr td:nth-child(2) input[type='checkbox']:not(:checked)")
    end
  end
end
