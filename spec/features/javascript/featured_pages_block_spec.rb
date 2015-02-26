require "spec_helper"

describe "Featured Pages Blocks", type: :feature, js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let!(:page1) {
    FactoryGirl.create(
      :feature_page,
      title: "xyz",
      exhibit: exhibit
    )
  }

  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }

  before do
    login_as exhibit_curator
  end

  it 'should save the selected exhibits' do
    skip("Passing locally but Travis is throwing intermittent errors") if ENV["CI"]
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)

    click_link("Edit")

    add_widget 'featured_pages'
    
    fill_in_typeahead_field "page-grid-id_0_title", with: "xyz"
    
    save_page
    
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)

    expect(page).to have_content "xyz"
  end

end
