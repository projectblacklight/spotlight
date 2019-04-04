# frozen_string_literal: true

feature 'Uploaded Items Block', feature: true, js: true, versioning: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
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
      fill_in 'Caption', with: 'Some caption text'
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
      expect(page).to have_css '.caption', text: 'Some caption text'
      expect(page).to have_css('img[alt="avatar.png"]')
    end
  end

  scenario 'users can toggle individual images to not display' do
    attach_file('uploaded_item_url', fixture_file1)
    attach_file('uploaded_item_url', fixture_file2)

    # This line blocks until the javascript has added the file to the page:
    expect(find('#st-block-3_display-checkbox_2')).to be_present

    # Uncheck the first checkbox
    all('input[type="checkbox"]').first.click

    save_page

    within('.uploaded-items-block') do
      expect(page).not_to have_css('img[alt="800x600.png"]')
      expect(page).to have_css('img[alt="avatar.png"]')
    end
  end
end
