require 'spec_helper'

feature 'Block preview' do
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
  end

  scenario 'should allow you to preview a widget', js: true do
    add_widget 'solr_documents'
    fill_in_typeahead_field with: 'dq287tq6352'

    # display the title as the primary caption
    within('.primary-caption') do
      check('Primary caption')
      select('Title', from: 'primary-caption-field')
    end

    # Preview page
    find('a[data-icon="preview"]').trigger('click')
    # verify that the page was previewed
    expect(page).to have_css('.preview')
    # verify that the item + image widget is displaying an image from the document.
    within(:css, '.preview') do
      expect(page).to have_css 'img'
      expect(page).to have_content "L'AMERIQUE"
    end
  end
end
