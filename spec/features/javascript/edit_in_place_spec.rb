# frozen_string_literal: true

RSpec.describe 'Edit in place', js: true, type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit:) }

  before { login_as admin }

  describe 'Feature Pages' do
    it 'updates the label' do
      visit spotlight.exhibit_dashboard_path(exhibit)

      click_link 'Feature pages'

      add_new_via_button('My New Feature Page')

      expect(page).to have_css('h3', text: 'My New Feature Page')

      within('.feature_pages_admin') do
        expect(page).to have_css('#exhibit_feature_pages_attributes_0_title[type="hidden"]', visible: false)
        expect(page).to have_no_css('#exhibit_feature_pages_attributes_0_title[type="text"]')
        click_link('My New Feature Page')
        expect(page).to have_no_css('#exhibit_feature_pages_attributes_0_title[type="hidden"]')
        expect(page).to have_css('#exhibit_feature_pages_attributes_0_title[type="text"]')
        fill_in 'exhibit_feature_pages_attributes_0_title', with: 'My Newer Feature Page'
      end
      click_button 'Save changes'

      expect(page).to have_content('Feature pages were successfully updated.')
      expect(page).to have_css('h3', text: 'My Newer Feature Page')
      expect(page).to have_no_css('h3', text: 'My New Feature Page')
    end

    it 'rejects blank values' do
      skip('Throws Selenium::WebDriver::Error::ElementNotInteractableError')
      skip('Passes locally, but soooo flakey on Travis.') if ENV['CI']
      visit spotlight.exhibit_dashboard_path(exhibit)

      click_link 'Feature pages'

      add_new_via_button('My New Feature Page')

      expect(page).to have_css('h3', text: 'My New Feature Page')

      within('.feature_pages_admin') do
        expect(page).to have_css('#exhibit_feature_pages_attributes_0_title[type="hidden"]', visible: false)
        expect(page).to have_no_css('#exhibit_feature_pages_attributes_0_title[type="text"]')
        click_link('My New Feature Page')
        expect(page).to have_no_css('#exhibit_feature_pages_attributes_0_title[type="hidden"]')
        expect(page).to have_css('#exhibit_feature_pages_attributes_0_title[type="text"]')
        fill_in 'exhibit_feature_pages_attributes_0_title', with: ''
        # blur out of the now-emptytitle field
        field = page.find_field('exhibit_feature_pages_attributes_0_title')
        field.native.send_keys :tab

        expect(page).to have_css('#exhibit_feature_pages_attributes_0_title[type="hidden"]', visible: false)
        expect(page).to have_no_css('#exhibit_feature_pages_attributes_0_title[type="text"]')
        expect(page).to have_css('h3', text: 'My New Feature Page')
      end
    end
  end

  describe 'Main navigation' do
    it 'updates the Appearance label' do
      visit spotlight.exhibit_dashboard_path(exhibit)

      within '#sidebar' do
        click_link 'Appearance'
      end

      click_link 'Main menu'

      within('#nested-navigation') do
        expect(page).to have_css("#exhibit_main_navigations_attributes_0_label[type='hidden']", visible: false)
        expect(page).to have_no_css("#exhibit_main_navigations_attributes_0_label[type='text']")
        click_link('Curated features')
        expect(page).to have_no_css("#exhibit_main_navigations_attributes_0_label[type='hidden']")
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

    it 'updates the metadata label', max_wait_time: 10 do
      visit spotlight.exhibit_dashboard_path(exhibit)

      within '#sidebar' do
        click_link 'Metadata'
      end

      within('.metadata_fields') do
        expect(page).to have_css("[data-id='personal_name_ssm'][data-behavior='restore-default']", visible: true)
        expect(page).to have_no_selector('button[name="button"][type="submit"][data-restore-default="true"]', text: 'Restore default')
        click_link('Personal names')
        fill_in 'blacklight_configuration_index_fields_personal_name_ssm_label', with: 'Brand new name'
      end

      click_button 'Save changes'

      within('.metadata_fields') do
        expect(page).to have_css('a[href="#edit-in-place"]', text: 'Brand new name')
        expect(page).to have_selector('button[name="button"][type="submit"][data-restore-default="true"]', text: 'Restore default', visible: true)
      end

      click_button 'Restore default'
      click_button 'Save changes'

      within('.metadata_fields') do
        expect(page).to have_css('a[href="#edit-in-place"]', text: 'Personal names')
        expect(page).to have_no_selector('button[name="button"][type="submit"][data-restore-default="true"]', text: 'Restore default')
      end
    end
  end
end
