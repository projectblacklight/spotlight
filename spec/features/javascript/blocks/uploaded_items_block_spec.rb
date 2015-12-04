require 'spec_helper'

feature 'Uploaded Items Block', feature: true, js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  let(:fixture_file1) { File.join(FIXTURES_PATH, '800x600.png') }
  let(:fixture_file2) { File.join(FIXTURES_PATH, 'avatar.png') }

  before do
    login_as exhibit_curator
    visit spotlight.edit_exhibit_home_page_path(exhibit)
    add_widget 'uploaded_items'
  end

  scenario 'users can upload images with text' do
    heading = 'Some Uploaded Images'
    text = 'Take a look at these images I just uploaded!'
    fill_in 'Heading', with: heading
    content_editable = find('.st-text-block')
    content_editable.set(text)

    expect(page).not_to have_css('.dd-list li')
    attach_file('uploaded_item_url', fixture_file1)

    expect(page).to have_css('.dd-list li', count: 1)
    within('.dd-list') do
      expect(page).to have_css('.panel-title', text: '800x600.png')
    end

    attach_file('uploaded_item_url', fixture_file2)

    expect(page).to have_css('.dd-list li', count: 2)
    within('.dd-list') do
      expect(page).to have_css('.panel-title', text: 'avatar.png')
    end

    save_page

    expect(page).to have_css('h3', text: heading)
    expect(page).to have_css('p', text: text)

    within('.uploaded-items-block') do
      expect(page).to have_css('img[alt="800x600.png"]')
      expect(page).to have_css('img[alt="avatar.png"]')
    end
  end

  scenario 'users can toggle individual images to not display' do
    attach_file('uploaded_item_url', fixture_file1)
    attach_file('uploaded_item_url', fixture_file2)

    within('.panel') do
      uncheck 'Display?'
    end

    save_page

    within('.uploaded-items-block') do
      expect(page).not_to have_css('img[alt="800x600.png"]')
      expect(page).to have_css('img[alt="avatar.png"]')
    end
  end
end
