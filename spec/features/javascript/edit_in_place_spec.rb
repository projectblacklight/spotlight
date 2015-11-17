require 'spec_helper'

describe 'Edit in place', type: :feature, js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:admin) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
  before { login_as admin }
  describe 'Feature Pages' do
    it 'updates the label' do
      visit spotlight.exhibit_dashboard_path(exhibit)

      click_link 'Feature pages'

      add_new_page_via_button('My New Feature Page')

      expect(page).to have_css('h3', text: 'My New Feature Page')

      within('.feature_pages_admin') do
        expect(page).to have_css('#exhibit_feature_pages_attributes_0_title[type="hidden"]', visible: false)
        expect(page).not_to have_css('#exhibit_feature_pages_attributes_0_title[type="text"]')
        click_link('My New Feature Page')
        expect(page).not_to have_css('#exhibit_feature_pages_attributes_0_title[type="hidden"]')
        expect(page).to have_css('#exhibit_feature_pages_attributes_0_title[type="text"]')
        fill_in 'exhibit_feature_pages_attributes_0_title', with: 'My Newer Feature Page'
      end
      click_button 'Save changes'

      expect(page).to have_content('Feature pages were successfully updated.')
      expect(page).to have_css('h3', text: 'My Newer Feature Page')
      expect(page).to_not have_css('h3', text: 'My New Feature Page')
    end
  end
  describe 'Main navigation' do
    it 'updates the label' do
      visit spotlight.exhibit_dashboard_path(exhibit)

      within '#sidebar' do
        click_link 'Appearance'
      end

      click_link 'Main menu'

      within('#nested-navigation') do
        expect(page).to have_css("#exhibit_main_navigations_attributes_0_label[type='hidden']", visible: false)
        expect(page).not_to have_css("#exhibit_main_navigations_attributes_0_label[type='text']")
        click_link('Curated Features')
        expect(page).not_to have_css("#exhibit_main_navigations_attributes_0_label[type='hidden']")
        expect(page).to have_css("#exhibit_main_navigations_attributes_0_label[type='text']")
        fill_in 'exhibit_main_navigations_attributes_0_label', with: 'My Page Label'
      end

      click_button 'Save changes'

      expect(page).to have_content('The exhibit was successfully updated.')

      click_link 'Main menu'

      within('#nested-navigation') do
        expect(page).to have_css('h3', text: 'My Page Label')
      end
    end
  end
end
