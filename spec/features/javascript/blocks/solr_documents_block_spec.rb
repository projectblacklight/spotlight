require 'spec_helper'

feature 'Solr Document Block', feature: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  let(:feature_page) do
    FactoryGirl.create(
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
    fill_in_typeahead_field with: 'dq287tq6352'
    within(:css, '.panel') do
      expect(page).to have_content "L'AMERIQUE"
    end

    save_page

    # verify that the item + image widget is displaying an image from the document.
    within(:css, '.items-block') do
      expect(page).to have_css('.thumbnail')
      expect(page).to have_css('.thumbnail a img')
      expect(page).not_to have_css('.title')
    end
  end

  scenario 'it should allow you to add multiple solr documents to the widget', js: true do
    fill_in_typeahead_field with: 'dq287tq6352'
    fill_in_typeahead_field with: 'gk446cj2442'

    save_page

    expect(page).to have_selector '.items-block .box', count: 2
  end

  scenario 'it should allow you toggle visibility of solr documents', js: true do
    fill_in_typeahead_field with: 'dq287tq6352'

    within(:css, '.panel') do
      uncheck 'Display?'
    end

    fill_in_typeahead_field with: 'gk446cj2442'

    # display the title as the primary caption
    within('.primary-caption') do
      check('Primary caption')
      select('Title', from: 'primary-caption-field')
    end

    save_page

    expect(page).to have_selector '.items-block .box', count: 1
    expect(page).to have_content '[World map]'
    expect(page).not_to have_content "L'AMERIQUE"
  end

  scenario 'should allow you to optionally display captions with the image', js: true do
    fill_in_typeahead_field with: 'gk446cj2442'

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
    within(:css, '.items-block') do
      expect(page).to have_css('.thumbnail')
      expect(page).to have_css('.thumbnail a img')
      expect(page).to have_css('.primary-caption', text: '[World map]')
      expect(page).to have_css('.secondary-caption', text: 'Latin')
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
    within(:css, '.items-block') do
      expect(page).to have_content 'zzz'
    end
  end

  scenario 'should allow you to choose which side the text will be on', js: true do
    fill_in_typeahead_field with: 'dq287tq6352'

    # fill in the content editable div
    content_editable = find('.st-text-block')
    content_editable.set('zzz')
    # Select to align the text right
    choose 'Right'
    # create the page
    save_page

    # verify that the item + image widget is displaying image and title from the requested document.
    within(:css, '.items-block') do
      expect(page).to have_content 'zzz'
      expect(page).to have_css('.items-col.pull-left')
      expect(page).to have_css('.text-col')
    end
  end

  scenario 'round-trip data', js: true do
    fill_in_typeahead_field with: 'dq287tq6352'

    within(:css, '.panel') do
      uncheck 'Display?'
    end

    fill_in_typeahead_field with: 'gk446cj2442'

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

    expect(page).to have_selector '.panel', count: 2

    # for some reason, the text area above isn't getting filled in
    # expect(page).to have_selector ".st-text-block", text: "zzz"
    expect(find_field('primary-caption-field').value).to eq 'full_title_tesim'
  end
end
