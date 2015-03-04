require "spec_helper"

describe "Featured Browse Categories Block", type: :feature, js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let!(:all_searches) { exhibit.searches.where(title: "All Exhibit Items").first }
  let!(:search1) { FactoryGirl.create(:published_search, exhibit: exhibit, title: "Title1") }
  let!(:search2) { FactoryGirl.create(:published_search, exhibit: exhibit, title: "Title2") }
  let!(:search3) { FactoryGirl.create(:search, exhibit: exhibit, title: "Unpublished search") }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }

  before do
    login_as exhibit_curator
    all_searches.on_landing_page = true
    all_searches.save
  end

  it 'should save the selected exhibits' do
    skip("Passing locally but Travis is throwing intermittent errors") if ENV["CI"]
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)

    click_link("Edit")

    add_widget 'featured_browse_categories'

    expect(find('[name="display-item-counts"]')).to be_checked

    expect(page).to have_css('.panel-title', text: all_searches.title)
    expect(page).to have_css('.panel-title', text: search1.title)
    expect(page).to have_css('.panel-title', text: search2.title)
    expect(page).to_not have_css('.panel-title', text: "Unpublished search")

    check(search1.slug)

    save_page

    expect(page).to_not have_css('.category-title', text: all_searches.title)
    expect(page).to_not have_css('.category-title', text: search2.title)
    expect(page).to have_css('.category-title', text: search1.title)
    expect(page).to have_css('.item-count', text: /\d+ items/i)
  end

end
