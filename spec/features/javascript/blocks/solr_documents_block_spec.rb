# frozen_string_literal: true

RSpec.describe 'Solr Document Block', feature: true, js: true, max_wait_time: 30 do
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

  it 'allows you to add solr documents to the widget' do
    expect(page).to have_text 'This widget displays exhibit items in a horizontal row.'
    expect(page).to have_text 'Optionally, you can add a heading and/or text to be displayed adjacent to the items.'
    expect(page).to have_text 'Primary caption'
    expect(page).to have_text 'Secondary caption'
    expect(page).to have_text 'Display text on'
    expect(page).to have_text('For each item, please enter alternative text')
    expect(page).to have_link('Guidelines for writing alt text.', href: 'https://www.w3.org/WAI/tutorials/images/')

    fill_in_solr_document_block_typeahead_field with: 'dq287tq6352'
    within(:css, '.card') do
      expect(page).to have_text "L'AMERIQUE"
    end

    item_id = page.find('li[data-resource-id="dq287tq6352"]')[:id]
    index_id = page.find('li[data-resource-id="dq287tq6352"]')['data-id']
    image_selection_url = "/spotlight/#{exhibit.slug}/select_image?block_item_id=#{item_id}&index_id=#{index_id}"
    expect(page).to have_link('Select image area', href: image_selection_url)

    fill_in_solr_document_block_typeahead_field with: 'gk446cj2442'
    expect(page).to have_css '.panels li', count: 2, visible: true

    save_page_changes

    # verify that the item + image widget is displaying images from the documents.
    within(:css, '.items-block', visible: true) do
      expect(page).to have_css '.box', count: 2, visible: true
      expect(page).to have_css('.img-thumbnail')
      expect(page).to have_no_css('.title')
    end
  end

  it 'allows you to choose from a multi-image solr document (and persist through edits)' do
    fill_in_solr_document_block_typeahead_field with: 'xd327cm9378'

    expect(page).to have_css('[data-panel-image-pagination]', text: /Image 1 of 2/, visible: true)

    # Select the last image
    click_link('Change')
    find('.thumbs-list li[data-index="1"]').click
    expect(page).to have_css('[data-panel-image-pagination]', text: /Image 2 of 2/, visible: true)

    save_page_changes

    # The thumbnail on the rendered block should be correct
    thumb = find('.img-thumbnail')
    expect(thumb['src']).to include('xd327cm9378_05_0002/full')

    # revisit the edit page
    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)

    # Expect the image on the rendered edit screen to be correct
    expect(page).to have_css('[data-panel-image-pagination]', text: /Image 2 of 2/, visible: true)
    thumb = find('.pic .img-thumbnail')
    expect(thumb['src']).to include('xd327cm9378_05_0002/full')

    save_page_changes

    # Expect that the original image selection was retained
    thumb = find('.img-thumbnail')
    expect(thumb['src']).to include('xd327cm9378_05_0002/full')
  end

  it 'round-trips item visibility, captions, and text through edits' do
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
    # display the language as the secondary caption
    within('.secondary-caption') do
      check('Secondary caption')
      select('Language', from: 'secondary-caption-field')
    end

    # fill in the content-editable div and put the text on the left
    find('.st-text-block').set('zzz')
    choose 'Left'

    save_page_changes

    within(:css, '.items-block', visible: true) do
      expect(page).to have_css '.box', count: 1, visible: true
      expect(page).to have_css('.img-thumbnail')
      expect(page).to have_css('.primary-caption', text: '[World map]')
      expect(page).to have_css('.secondary-caption', text: 'Latin')
      expect(page).to have_no_text "L'AMERIQUE"
      within('.text-col') do
        expect(page).to have_text 'zzz'
      end
      expect(page).to have_css('.items-col.float-end')
    end

    expect(page).to be_axe_clean.within '#content'

    click_on 'Edit'

    # Wait for both items to be rendered
    wait_for_sir_trevor
    expect(page).to have_css '.card', count: 2, visible: true
    expect(page).to have_text '[World map]'
    expect(page).to have_text "L'AMERIQUE"
    expect(find_field('primary-caption-field').value).to eq Spotlight::PageConfigurations::DOCUMENT_TITLE_KEY

    uncheck('Primary caption')

    save_page_changes

    expect(page).to have_css '.items-block .box', count: 1, visible: true
    expect(page).to have_no_text '[World map]'
  end

  it 'allows you to optionally display a ZPR link with the image' do
    fill_in_solr_document_block_typeahead_field with: 'gk446cj2442'

    check 'Offer "View larger" option'

    save_page_changes

    expect(page).to be_axe_clean.within '#content'
    within '.contents' do
      click_button 'View [World map] larger'
    end

    within '.modal-content' do
      expect(page).to have_css('#osd-modal-container')
      expect(page).to have_css('.openseadragon-container')
    end
  end

  it 'retains custom alt text after marking as decorative and saving' do
    fill_in_solr_document_block_typeahead_field with: 'gk446cj2442'

    fill_in 'Alternative text', with: 'custom alt text'
    check 'Decorative'
    expect(page).to have_field('Alternative text', type: 'textarea', disabled: true, placeholder: '', with: '')
    save_page_changes
    click_on 'Edit'

    # Wait for the item to be rendered
    wait_for_sir_trevor
    expect(page).to have_text '[World map]'
    uncheck 'Decorative'

    expect(page).to have_field('Alternative text', type: 'textarea', disabled: false, with: 'custom alt text')
  end
end
