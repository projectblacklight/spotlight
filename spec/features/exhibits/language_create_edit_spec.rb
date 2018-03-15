describe 'Language', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }
  before do
    login_as admin
    visit spotlight.edit_exhibit_path(exhibit)
  end
  describe 'creation' do
    it 'successfully adds languages' do
      within '#language' do
        select 'Albanian'
        click_button 'Add language'
      end
      expect(page).to have_css '.flash_messages', text: 'The language was created.'
      within '#language' do
        expect(page).to have_css 'table'
        expect(page).to have_css 'td', text: 'Albanian'
      end
    end
  end
  describe 'making public' do
    it 'successfully updates the language' do
      within '#language' do
        select 'Albanian'
        click_button 'Add language'
      end
      expect(page).to have_css '.flash_messages', text: 'The language was created.'
      within '#language' do
        check 'Public'
        click_button 'Save changes'
      end
      expect(page).to have_css '.flash_messages', text: 'The exhibit was successfully updated.'
      expect(exhibit.languages.last).to be_public
    end
  end
  describe 'deleting' do
    it 'successfully updates the language' do
      within '#language' do
        select 'Albanian'
        click_button 'Add language'
      end
      expect(page).to have_css '.flash_messages', text: 'The language was created.'
      within '#language' do
        click_link 'Remove'
      end
      expect(page).to have_css '.flash_messages', text: 'The language was deleted.'
      within '#language' do
        expect(page).to have_content 'No languages have been added for translation. To add a language, make a selection above.'
        expect(page).not_to have_css 'table'
      end
    end
  end
end
