require 'spec_helper'

describe 'Slideshow', type: :feature, js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:user) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }

  before do
    login_as user
    exhibit.blacklight_configuration.update(document_index_view_types: %w(list gallery slideshow))
  end
  it 'has slideshow' do
    visit spotlight.exhibit_catalog_index_path(exhibit, f: { genre_ssim: ['map'] })
    expect(page).to have_content 'You searched for:'
    within '.view-type' do
      click_link 'Slideshow'
    end
    find('.grid [data-slide-to="1"]').trigger('click')
    expect(page).to have_selector '#slideshow', visible: true
  end
end
