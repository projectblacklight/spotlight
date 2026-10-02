# frozen_string_literal: true

RSpec.describe 'Solr Documents Carousel Block', js: true, type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }

  let!(:feature_page) { FactoryBot.create(:feature_page, exhibit:) }

  before do
    login_as exhibit_curator

    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)
    add_widget 'solr_documents_carousel'
  end

  it 'allows a curator to select a caption to display' do
    fill_in_typeahead_field with: 'dq287tq6352'

    check 'Primary caption'
    select 'Title', from: 'primary-caption-field'

    save_page_changes

    within '.carousel-block' do
      expect(page).to have_css('.carousel-item', count: 1)
      # Images are disabled in tests, so the carousel item has no height
      expect(page).to have_css('.carousel-caption .primary', text: "L'AMERIQUE", visible: :all)
    end
  end

  it 'allows users to stop and start autoplay with button' do
    fill_in_typeahead_field with: 'dq287tq6352'
    save_page_changes

    within '.carousel-block' do
      button = find('button.carousel-pause-play')
      button.click
      expect(button).to have_css('[aria-label="Start automatic slide show"] .carousel-play-icon')
      expect(button).to have_no_css('.carousel-pause-icon')
      expect(page).to have_css('.carousel-inner[aria-live="polite"]', visible: :all)

      button.click
      expect(button).to have_css('[aria-label="Stop automatic slide show"] .carousel-pause-icon')
      expect(button).to have_no_css('.carousel-play-icon')
      expect(page).to have_css('.carousel-inner[aria-live="off"]', visible: :all)
    end
  end

  it 'stops autoplay when keyboard focus enters the carousel' do
    fill_in_typeahead_field with: 'dq287tq6352'
    save_page_changes
    button = find('.carousel-block button.carousel-pause-play')

    within '.carousel-block' do
      find('.carousel-control-next').send_keys('')
      expect(button).to have_css('[aria-label="Start automatic slide show"] .carousel-play-icon')
      expect(button).to have_no_css('.carousel-pause-icon')
      expect(page).to have_css('.carousel-inner[aria-live="polite"]', visible: :all)
    end

    # Moving keyboard focus out of the carousel doesn't restart autoplay
    find('.site-title-container a').send_keys('')
    within '.carousel-block' do
      expect(button).to have_css('[aria-label="Start automatic slide show"] .carousel-play-icon')
      expect(button).to have_no_css('.carousel-pause-icon')
      expect(page).to have_css('.carousel-inner[aria-live="polite"]', visible: :all)
    end
  end

  it 'is accessible' do
    fill_in_typeahead_field with: 'dq287tq6352'
    check 'Primary caption'
    select 'Title', from: 'primary-caption-field'
    save_page_changes

    expect(page).to be_axe_clean.within '#content'
  end
end
