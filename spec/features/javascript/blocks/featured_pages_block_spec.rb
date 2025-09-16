# frozen_string_literal: true

RSpec.describe 'Featured Pages Blocks', js: true, type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let!(:feature_page1) do
    FactoryBot.create(
      :feature_page,
      title: 'FeaturePage1 Title',
      weight: 1,
      exhibit:
    )
  end
  let!(:feature_page2) do
    FactoryBot.create(
      :feature_page,
      title: 'FeaturePage2 Title',
      weight: 0,
      exhibit:
    )
  end

  # TODO: Change to exhibit curator role once issue #3249 is fixed
  let(:site_admin) { FactoryBot.create(:site_admin) }

  before do
    login_as site_admin
  end

  it 'saves the selected exhibits' do
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)

    click_link('Edit')

    add_widget 'featured_pages'

    fill_in_typeahead_field with: feature_page2.title

    save_page_changes

    expect(page).to have_content feature_page2.title
  end

  it 'does not display the select image area link' do
    visit spotlight.edit_exhibit_home_page_path(exhibit)

    add_widget 'featured_pages'

    fill_in_typeahead_field with: feature_page2.title

    # Verify that select image area link is not visible
    expect(page).to have_no_link('Select image area')
  end

  pending 'persists the user selected sort order' do
    pending('Prefetched autocomplete does not work the same way as solr-backed autocompletes')
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)

    click_link('Edit')

    add_widget 'featured_pages'

    fill_in_typeahead_field with: feature_page1.title
    fill_in_typeahead_field with: feature_page2.title

    save_page_changes

    feature_page1_position = page.body =~ /<p class="category-title">\s+#{feature_page1.title}/
    feature_page2_position = page.body =~ /<p class="category-title">\s+#{feature_page2.title}/

    expect(feature_page1_position).to be < feature_page2_position
  end
end
