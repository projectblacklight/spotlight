# frozen_string_literal: true

describe 'Block controls' do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }

  before { login_as exhibit_curator }

  it 'is split into separate sections', js: true do
    # create page
    visit spotlight.exhibit_dashboard_path(exhibit)

    click_link 'Feature pages'

    add_new_via_button('My New Feature Page')

    expect(page).to have_css('h3', text: 'My New Feature Page')

    expect(page).to have_content('The feature page was created.')
    within('li.dd-item') do
      click_link 'Edit'
    end
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
        expect(page).to have_content 'Standard widgets'
        expect(page).to have_css('.st-block-controls__button')
      end

      within(all('.st-controls-group').last) do
        expect(page).to have_content 'Exhibit item widgets'
        expect(page).to have_css('.st-block-controls__button')
      end
    end
  end
end
