require 'spec_helper'

describe 'Featured Pages Blocks', type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let!(:feature_page) do
    FactoryGirl.create(
      :feature_page,
      title: 'xyz',
      exhibit: exhibit
    )
  end

  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }

  before do
    login_as exhibit_curator
  end

  it 'saves the selected exhibits', js: true do
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)

    click_link('Edit')

    add_widget 'featured_pages'

    fill_in_typeahead_field with: 'xyz'

    save_page

    expect(page).to have_content 'xyz'
  end
end
