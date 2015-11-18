require 'spec_helper'

describe 'Featured Pages Blocks', type: :feature, js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let!(:feature_page1) do
    FactoryGirl.create(
      :feature_page,
      title: 'FeaturePage1 Title',
      weight: 1,
      exhibit: exhibit
    )
  end
  let!(:feature_page2) do
    FactoryGirl.create(
      :feature_page,
      title: 'FeaturePage2 Title',
      weight: 0,
      exhibit: exhibit
    )
  end

  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }

  before do
    login_as exhibit_curator
  end

  it 'saves the selected exhibits' do
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)

    click_link('Edit')

    add_widget 'featured_pages'

    fill_in_typeahead_field with: feature_page2.title

    save_page

    expect(page).to have_content feature_page2.title
  end

  it 'persists the user selected sort order' do
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)

    click_link('Edit')

    add_widget 'featured_pages'

    fill_in_typeahead_field with: feature_page1.title
    fill_in_typeahead_field with: feature_page2.title

    save_page

    feature_page1_position = page.body =~ /<p class="category-title">\s+#{feature_page1.title}/
    feature_page2_position = page.body =~ /<p class="category-title">\s+#{feature_page2.title}/

    expect(feature_page1_position).to be < feature_page2_position
  end
end
