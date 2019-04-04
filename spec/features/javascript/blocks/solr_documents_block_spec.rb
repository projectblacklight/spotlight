# frozen_string_literal: true

feature 'Solr Document Block', feature: true, versioning: true, default_max_wait_time: 15 do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
  let(:feature_page) do
    FactoryBot.create(
      :feature_page,
      title: 'FeaturePage1',
      exhibit: exhibit
    )
  end

  before do
    login_as exhibit_curator
    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)
    add_widget 'solr_documents'
  end

  scenario 'it should allow you to add the solr document block widget', js: true do
    expect(page).to have_content 'This widget displays exhibit items in a horizontal row.'
    expect(page).to have_content 'Optionally, you can add a heading and/or text to be displayed adjacent to the items.'
    expect(page).to have_content 'Primary caption'
    expect(page).to have_content 'Secondary caption'
    expect(page).to have_content 'Display text on'
    expect(page).to have_content 'Heading'
    expect(page).to have_content 'Text'
  end

  scenario 'it should allow you to add a solr document to the widget', js: true do
    fill_in_solr_document_block_typeahead_field with: 'dq287tq6352'
    within(:css, '.panel') do
      expect(page).to have_content "L'AMERIQUE"
    end

    save_page

    # verify that the item + image widget is displaying an image from the document.
    within(:css, '.items-block', visible: true) do
      expect(page).to have_css('.thumbnail')
      expect(page).to have_css('.thumbnail a img')
      expect(page).not_to have_css('.title')
    end
  end

  scenario 'it should allow you to add multiple solr documents to the widget', js: true do
    fill_in_solr_document_block_typeahead_field with: 'dq287tq6352'
    fill_in_solr_document_block_typeahead_field with: 'gk446cj2442'
    expect(page).to have_selector '.panels li', count: 2, visible: true

    save_page

    expect(page).to have_selector '.items-block .box', count: 2, visible: true
  end

  scenario 'it should allow you to choose from a multi-image solr document (and persist through edits)', js: true, default_max_wait_time: 30 do
    fill_in_solr_document_block_typeahead_field with: 'xd327cm9378'

    expect(page).to have_css('[data-panel-image-pagination]', text: /Image 1 of 2/, visible: true)

    # Select the last image
    click_link('Change')
    find('.thumbs-list li[data-index="1"]').click
    expect(page).to have_css('[data-panel-image-pagination]', text: /Image 2 of 2/, visible: true)

    save_page

    # The thumbnail on the rendered block should be correct
    thumb = find('.thumbnail img')
    expect(thumb['src']).to match(%r{xd327cm9378_05_0002/full})

    # revisit the edit page
    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)

    # Expect the image on the rendered edit screen to be correct
    expect(page).to have_css('[data-panel-image-pagination]', text: /Image 2 of 2/, visible: true)
    thumb = find('.pic.thumbnail img')
    expect(thumb['src']).to match(%r{xd327cm9378_05_0002/full})

    save_page

    # Expect that the original image selection was retained
    thumb = find('.thumbnail img')
    expect(thumb['src']).to match(%r{xd327cm9378_05_0002/full})
  end

  scenario 'it should allow you toggle visibility of solr documents', js: true do
    fill_in_solr_document_block_typeahead_field with: 'dq287tq6352'

    within(:css, '.panel') do
      uncheck 'Display?'
    end

    fill_in_solr_document_block_typeahead_field with: 'gk446cj2442'

    # display the title as the primary caption
    within('.primary-caption') do
      check('Primary caption')
      select('Title', from: 'primary-caption-field')
    end

    save_page

    expect(page).to have_selector '.items-block .box', count: 1, visible: true
    expect(page).to have_content '[World map]'
    expect(page).not_to have_content "L'AMERIQUE"
  end

  scenario 'should allow you to optionally display captions with the image', js: true do
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
    save_page

    # verify that the item + image widget is displaying image and title from the requested document.
    within(:css, '.items-block', visible: true) do
      expect(page).to have_css('.thumbnail')
      expect(page).to have_css('.thumbnail a img')
      expect(page).to have_css('.primary-caption', text: '[World map]')
      expect(page).to have_css('.secondary-caption', text: 'Latin')
    end
  end

  scenario 'should allow you to optionally display a ZPR link with the image', js: true do
    fill_in_solr_document_block_typeahead_field with: 'gk446cj2442'

    check 'Display ZPR link'
    # this seems silly, but also seems to help with the flappy-ness of this spec
    expect(find_field('Display ZPR link', checked: true)).to be_checked

    save_page

    within '.contents' do
      click_button 'Show in ZPR viewer'
    end

    within '.modal-content' do
      expect(page).to have_css('#osd-modal-container')
    end
  end

  scenario 'should allow you to add text to the image', js: true do
    # fill in the content-editable div
    content_editable = find('.st-text-block')
    content_editable.set('zzz')
    # create the page
    save_page

    # visit the show page for the document we just saved
    # verify that the item + image widget is displaying image and title from the requested document.
    within(:css, '.items-block', visible: true) do
      expect(page).to have_content 'zzz'
    end
  end

  scenario 'should allow you to choose which side the text will be on', js: true do
    fill_in_solr_document_block_typeahead_field with: 'dq287tq6352'

    # Select to align the text right
    choose 'Right'
    # this seems silly, but also seems to help with the flappy-ness of this spec
    expect(find_field('Right', checked: true)).to be_checked

    # fill in the content editable div
    content_editable = find('.st-text-block')
    content_editable.set('zzz')

    # create the page
    save_page

    # verify that the item + image widget is displaying image and title from the requested document.
    within(:css, '.items-block') do
      within('.text-col') do
        expect(page).to have_content 'zzz'
      end
      expect(page).to have_css('.items-col.pull-left')
    end
  end

  scenario 'round-trip data', js: true do
    fill_in_solr_document_block_typeahead_field with: 'dq287tq6352'

    within(:css, '.panel') do
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

    save_page

    click_on 'Edit'

    expect(page).to have_selector '.panel', count: 2, visible: true

    # for some reason, the text area above isn't getting filled in
    # expect(page).to have_selector ".st-text-block", text: "zzz"
    expect(find_field('primary-caption-field').value).to eq 'full_title_tesim'
  end
end
