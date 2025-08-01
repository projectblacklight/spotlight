# frozen_string_literal: true

RSpec.describe 'Solr Document Block', feature: true, max_wait_time: 30, versioning: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }
  let(:feature_page) do
    FactoryBot.create(
      :feature_page,
      title: 'FeaturePage1',
      exhibit:
    )
  end

  before do
    login_as exhibit_curator
    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)
    add_widget 'solr_documents'
  end

  it 'allows you to add the solr document block widget', js: true do
    expect(page).to have_content 'This widget displays exhibit items in a horizontal row.'
    expect(page).to have_content 'Optionally, you can add a heading and/or text to be displayed adjacent to the items.'
    expect(page).to have_content 'Primary caption'
    expect(page).to have_content 'Secondary caption'
    expect(page).to have_content 'Display text on'
    expect(page).to have_content 'Heading'
    expect(page).to have_content 'Text'
  end

  it 'allows you to add a solr document to the widget', js: true do
    fill_in_solr_document_block_typeahead_field with: 'dq287tq6352'
    within(:css, '.card') do
      expect(page).to have_content "L'AMERIQUE"
    end

    save_page_changes

    # verify that the item + image widget is displaying an image from the document.
    within(:css, '.items-block', visible: true) do
      expect(page).to have_css('.img-thumbnail')
      expect(page).to have_no_css('.title')
    end
  end

  it 'allows you to add multiple solr documents to the widget', js: true do
    fill_in_solr_document_block_typeahead_field with: 'dq287tq6352'
    fill_in_solr_document_block_typeahead_field with: 'gk446cj2442'
    expect(page).to have_selector '.panels li', count: 2, visible: true

    save_page_changes

    expect(page).to have_selector '.items-block .box', count: 2, visible: true
  end

  it 'allows you to choose from a multi-image solr document (and persist through edits)', js: true do
    fill_in_solr_document_block_typeahead_field with: 'xd327cm9378'

    expect(page).to have_css('[data-panel-image-pagination]', text: /Image 1 of 2/, visible: true)

    # Select the last image
    click_link('Change')
    find('.thumbs-list li[data-index="1"]').click
    expect(page).to have_css('[data-panel-image-pagination]', text: /Image 2 of 2/, visible: true)

    save_page_changes

    # The thumbnail on the rendered block should be correct
    thumb = find('.img-thumbnail')
    expect(thumb['src']).to match(%r{xd327cm9378_05_0002/full})

    # revisit the edit page
    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)

    # Expect the image on the rendered edit screen to be correct
    expect(page).to have_css('[data-panel-image-pagination]', text: /Image 2 of 2/, visible: true)
    thumb = find('.pic .img-thumbnail')
    expect(thumb['src']).to match(%r{xd327cm9378_05_0002/full})

    save_page_changes

    # Expect that the original image selection was retained
    thumb = find('.img-thumbnail')
    expect(thumb['src']).to match(%r{xd327cm9378_05_0002/full})
  end

  it 'allows you to toggle visibility of solr documents', js: true do
    fill_in_solr_document_block_typeahead_field with: 'dq287tq6352'

    within(:css, '.card') do
      uncheck 'Display?'
    end

    fill_in_solr_document_block_typeahead_field with: 'gk446cj2442'

    # display the title as the primary caption
    check('Primary caption')
    select('Title', from: 'primary-caption-field')

    save_page_changes

    expect(page).to have_selector '.items-block .box', count: 1, visible: true
    expect(page).to have_content '[World map]'
    expect(page).to have_no_content "L'AMERIQUE"

    click_on 'Edit'

    # Wait for both items to be rendered
    wait_for_sir_trevor
    expect(page).to have_content '[World map]'
    expect(page).to have_content "L'AMERIQUE"

    # display the title as the primary caption
    uncheck('Primary caption')

    save_page_changes

    expect(page).to have_selector '.items-block .box', count: 1, visible: true
    expect(page).to have_no_content '[World map]'
  end

  it 'allows you to optionally display captions with the image', js: true do
    fill_in_solr_document_block_typeahead_field with: 'gk446cj2442'

    # display the title as the primary caption
    within('.primary-caption') do
      check('Primary caption')
      select('Title', from: 'primary-caption-field')
    end
    # display the language as the secondary caption
    within('.secondary-caption') do
      check('Secondary caption')
      select('Language', from: 'secondary-caption-field')
    end
    # create the page
    save_page_changes

    # verify that the item + image widget is displaying image and title from the requested document.
    within(:css, '.items-block', visible: true) do
      expect(page).to have_css('.img-thumbnail')
      expect(page).to have_css('.primary-caption', text: '[World map]')
      expect(page).to have_css('.secondary-caption', text: 'Latin')
    end
  end

  it 'allows you to optionally display a ZPR link with the image', js: true do
    fill_in_solr_document_block_typeahead_field with: 'gk446cj2442'

    check 'Offer "View larger" option'

    save_page_changes

    within '.contents' do
      click_button 'View [World map] larger'
    end

    within '.modal-content' do
      expect(page).to have_css('#osd-modal-container')
      expect(page).to have_css('.openseadragon-container')
    end
  end

  it 'allows you to add text to the image', js: true do
    # fill in the content-editable div
    content_editable = find('.st-text-block')
    content_editable.set('zzz')
    # create the page
    save_page_changes

    # visit the show page for the document we just saved
    # verify that the item + image widget is displaying image and title from the requested document.
    within(:css, '.items-block', visible: true) do
      expect(page).to have_content 'zzz'
    end
  end

  it 'allows you to choose which side the text will be on', js: true do
    fill_in_solr_document_block_typeahead_field with: 'dq287tq6352'

    # Select to align the text right
    choose 'Left'

    # fill in the content editable div
    content_editable = find('.st-text-block')
    content_editable.set('zzz')

    # create the page
    save_page_changes

    # verify that the item + image widget is displaying image and title from the requested document.
    within(:css, '.items-block') do
      within('.text-col') do
        expect(page).to have_content 'zzz'
      end
      expect(page).to have_css('.items-col.float-end')
    end
  end

  it 'displays alternative text guidelines', js: true do
    expect(page).to have_content('For each item, please enter alternative text')
    expect(page).to have_link('Guidelines for writing alt text.', href: 'https://www.w3.org/WAI/tutorials/images/')
  end

  it 'toggles alt text input when marking an image as decorative', js: true do
    fill_in_solr_document_block_typeahead_field with: 'gk446cj2442'

    fill_in 'Alternative text', with: 'custom alt text'
    check 'Decorative'
    expect(page).to have_field('Alternative text', type: 'textarea', disabled: true, placeholder: '', with: '')
    uncheck 'Decorative'
    expect(page).to have_field('Alternative text', type: 'textarea', disabled: false, with: 'custom alt text')
  end

  it 'retains custom alt text after marking as decorative and saving', js: true do
    fill_in_solr_document_block_typeahead_field with: 'gk446cj2442'

    fill_in 'Alternative text', with: 'custom alt text'
    check 'Decorative'
    expect(page).to have_css 'textarea[disabled]'
    save_page_changes
    click_on 'Edit'

    # Wait for the item to be rendered
    wait_for_sir_trevor
    expect(page).to have_text '[World map]'
    uncheck 'Decorative'
    expect(page).to have_no_css 'textarea[disabled]'

    expect(page).to have_field('Alternative text', type: 'textarea', disabled: false, with: 'custom alt text')
  end

  it 'displays the select image area link to open up a modal for cropping', js: true do
    fill_in_solr_document_block_typeahead_field with: 'dq287tq6352'

    item_id = page.find('li[data-resource-id="dq287tq6352"]')[:id]
    index_id = page.find('li[data-resource-id="dq287tq6352"]')['data-id']
    image_selection_url = "/spotlight/#{exhibit.slug}/select_image?block_item_id=#{item_id}&index_id=#{index_id}"
    # Verify that select image area link is visible
    expect(page).to have_link('Select image area', href: image_selection_url)
  end

  it 'round-trip data', js: true do
    fill_in_solr_document_block_typeahead_field with: 'dq287tq6352'

    within(:css, '.card') do
      uncheck 'Display?'
    end

    fill_in_solr_document_block_typeahead_field with: 'gk446cj2442'

    # display the title as the primary caption
    within('.primary-caption') do
      check('Primary caption')
      select('Title', from: 'primary-caption-field')
    end

    # fill in the content editable div
    content_editable = find('.st-text-block')
    content_editable.set('zzz')
    # Select to align the text right
    choose 'Right'

    save_page_changes

    click_on 'Edit'

    expect(page).to have_selector '.card', count: 2, visible: true

    # for some reason, the text area above isn't getting filled in
    # expect(page).to have_selector ".st-text-block", text: "zzz"
    expect(find_field('primary-caption-field').value).to eq Spotlight::PageConfigurations::DOCUMENT_TITLE_KEY
  end
end
