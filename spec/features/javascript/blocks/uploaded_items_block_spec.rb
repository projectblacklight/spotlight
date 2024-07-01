# frozen_string_literal: true

describe 'Uploaded Items Block', feature: true, js: true, versioning: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
  let(:fixture_file1) { File.join(FIXTURES_PATH, '800x600.png') }
  let(:fixture_file2) { File.join(FIXTURES_PATH, 'avatar.png') }

  before do
    login_as exhibit_curator
    visit spotlight.edit_exhibit_home_page_path(exhibit)
    add_widget 'uploaded_items'
  end

  it 'users can upload images with text' do
    heading = 'Some Uploaded Images'
    text = 'Take a look at these images I just uploaded!'
    fill_in 'Heading', with: heading
    content_editable = find('.st-text-block')
    content_editable.set(text)

    expect(page).to have_no_css('.dd-list li')
    attach_file('uploaded_item_url', fixture_file1)

    expect(page).to have_css('.dd-list li', count: 1)
    within('.dd-list') do
      expect(page).to have_css('.card-title', text: '800x600.png')
      fill_in 'Caption', with: 'Some caption text'
      fill_in 'Link URL', with: 'https://example.com/'
    end

    attach_file('uploaded_item_url', fixture_file2)

    expect(page).to have_css('.dd-list li', count: 2)
    within('.dd-list') do
      expect(page).to have_css('.card-title', text: 'avatar.png')
    end

    save_page

    expect(page).to have_css('h3', text: heading)
    expect(page).to have_css('p', text: text)

    within('.uploaded-items-block') do
      expect(page).to have_css('img[alt=""]', count: 1)
      expect(page).to have_css('img[alt="Some caption text"]', count: 1)
      expect(page).to have_css '.caption', text: 'Some caption text'
      expect(page).to have_link 'Some caption text', href: 'https://example.com/'
    end
  end

  it 'users can toggle individual images to not display' do
    attach_file('uploaded_item_url', fixture_file1)
    attach_file('uploaded_item_url', fixture_file2)

    # This line blocks until the javascript has added the file to the page:
    expect(find('input[name="item[file_0][display]"]')).to be_present

    # Uncheck the first checkbox
    all('input[type="checkbox"]').first.click

    save_page

    within('.uploaded-items-block') do
      expect(page).to have_css('img[alt=""]', count: 1)
    end
  end

  it 'may have ZPR links' do
    attach_file('uploaded_item_url', fixture_file1)
    attach_file('uploaded_item_url', fixture_file2)

    check 'Offer "View larger" option'

    # Flappy guards. Wait for the thumbnail src to be populated.
    expect(page).to have_selector('li[data-id="file_0"] .img-thumbnail[src^="/"]')
    expect(page).to have_selector('li[data-id="file_1"] .img-thumbnail[src^="/"]')

    save_page

    within('.uploaded-items-block') do
      expect(page).to have_button('View larger', count: 2)
    end

    within first('.contents') do
      data = find('button')['data-iiif-tilesource']
      expect(data).to be_present
      expect(JSON.parse(data).with_indifferent_access).to include type: 'image', url: end_with('800x600.png')
      click_button 'View larger'
    end

    within '.modal-content' do
      expect(page).to have_css('#osd-modal-container')
    end
  end
end
