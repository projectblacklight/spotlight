require 'spec_helper'

feature 'Facets Administration', js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as exhibit_curator }
  it 'allows us to update the label with edit-in-place' do
    input_id = 'blacklight_configuration_facet_fields_genre_ssim_label'
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    click_link exhibit_curator.email

    within '#user-util-collapse .dropdown' do
      click_link 'Dashboard'
    end

    click_link 'Search facets'

    facet = find('.edit-in-place', text: 'Genre')
    expect(page).not_to have_content('Topic')
    expect(page).to have_css("input##{input_id}", visible: false)

    facet.click

    expect(page).to have_css("input##{input_id}", visible: true)

    fill_in(input_id, with: 'Topic')

    click_button 'Save changes'

    expect(page).to have_content('The exhibit was successfully updated.')

    expect(page).not_to have_content('Genre')
    expect(page).to have_content('Topic')
  end
end
