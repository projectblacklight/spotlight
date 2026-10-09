# frozen_string_literal: true

RSpec.describe 'Search Configuration Administration', js: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:user) { FactoryBot.create(:exhibit_admin, exhibit:) }

  before { login_as user }

  it 'allows the curator to update search field, facet, and sort field labels with edit-in-place' do
    visit spotlight.edit_exhibit_search_configuration_path(exhibit)

    click_link 'Options'

    within('#nested-search-fields') do
      expect(page).to have_css("#blacklight_configuration_search_fields_title_label[type='hidden']", visible: false)
      expect(page).to have_no_css("#blacklight_configuration_search_fields_title_label[type='text']")
      click_link('Title')
      expect(page).to have_no_css("#blacklight_configuration_search_fields_title_label[type='hidden']")
      expect(page).to have_css("#blacklight_configuration_search_fields_title_label[type='text']")
      fill_in 'blacklight_configuration_search_fields_title_label', with: 'My Title Label'
    end

    click_link 'Facets'

    facet_input_id = 'blacklight_configuration_facet_fields_genre_ssim_label'
    facet = find('.edit-in-place', text: 'Genre')
    expect(page).to have_css("input##{facet_input_id}", visible: false)
    facet.click
    expect(page).to have_css("input##{facet_input_id}", visible: true)
    fill_in(facet_input_id, with: 'Topic')

    click_link 'Results'

    within('#nested-sort-fields') do
      expect(page).to have_css("#blacklight_configuration_sort_fields_title_label[type='hidden']", visible: false)
      expect(page).to have_no_css("#blacklight_configuration_sort_fields_title_label[type='text']")
      click_link('title')
      expect(page).to have_no_css("#blacklight_configuration_sort_fields_title_label[type='hidden']")
      expect(page).to have_css("#blacklight_configuration_sort_fields_title_label[type='text']")
      fill_in 'blacklight_configuration_sort_fields_title_label', with: 'My Sort Label'
    end

    click_button 'Save changes'

    expect(page).to have_css('.alert', text: 'The exhibit was successfully updated.', visible: true)
    expect(page).to have_select 'Search in', with_options: ['My Title Label']

    click_link 'Facets'
    expect(page).to have_css('.edit-in-place', text: 'Topic')
    expect(page).to have_no_css('.edit-in-place', text: 'Genre')

    click_link 'Results'
    within('#nested-sort-fields') do
      expect(page).to have_css('h3', text: 'My Sort Label')
    end
  end

  describe 'search fields' do
    it 'allows the curator to disable all search fields' do
      visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
      expect(page).to have_select 'search_field'

      visit spotlight.edit_exhibit_search_configuration_path(exhibit)
      expect(page).to have_field 'enable_feature', visible: true
      uncheck 'Display search box'

      click_button 'Save changes'

      expect(page).to have_css('.alert', text: 'The exhibit was successfully updated.', visible: true)

      expect(page).to have_no_select 'search_field'
    end
  end
end
