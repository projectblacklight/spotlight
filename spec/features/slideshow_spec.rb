# frozen_string_literal: true

describe 'Slideshow', type: :feature, js: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:user) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }

  before do
    login_as user
    exhibit.blacklight_configuration.update(document_index_view_types: %w(list gallery slideshow))
  end

  it 'has slideshow' do
    visit spotlight.search_exhibit_catalog_path(exhibit, f: { genre_ssim: ['map'] })
    expect(page).to have_content 'You searched for:'
    within '.view-type' do
      click_link 'Slideshow'
    end
    find('.grid [data-slide-to="1"] img').click
    expect(page).to have_selector '#slideshow', visible: true
  end
end
