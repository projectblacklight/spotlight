# frozen_string_literal: true

RSpec.describe 'Block controls' do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }
  let(:feature_page) { FactoryBot.create(:feature_page, exhibit:) }

  before { login_as exhibit_curator }

  it 'is split into separate sections', js: true do
    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)
    # fill in title
    fill_in 'feature_page_title', with: 'Exhibit Title'
    # click to add widget
    click_add_widget

    # Check if the Sir Trevor icons are loading. They are in the same SVG so a single check should be sufficient.
    within('.st-block-replacer') do
      href_value = find('use')['xlink:href']
      expect(href_value).to match(/.+\.svg#add-block$/)
    end

    within('.spotlight-block-controls') do
      expect(page).to have_css('.st-controls-group', count: 2)

      within(first('.st-controls-group')) do
        expect(page).to have_text 'Standard widgets'
        expect(page).to have_css('.st-block-controls__button')
        expect(page).to have_button 'Pages'
      end

      within(all('.st-controls-group').last) do
        expect(page).to have_text 'Exhibit item widgets'
        expect(page).to have_css('.st-block-controls__button')
      end
    end
  end
end
