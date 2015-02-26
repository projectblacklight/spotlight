require "spec_helper"

describe "Featured Browse Categories Block", type: :feature, js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let!(:search1) { FactoryGirl.create(:search, exhibit: exhibit, title: "Title1") }
  let!(:search2) { FactoryGirl.create(:search, exhibit: exhibit, title: "Title2") }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  let(:all_items_title) { "All Exhibit Items" }

  before { login_as exhibit_curator }

  it 'should save the selected exhibits' do
    skip("Passing locally but Travis is throwing intermittent errors") if ENV["CI"]
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)

    click_link("Edit")

    add_widget 'featured_browse_categories'

    expect(find('[name="display-item-counts"]')).to be_checked

    expect(page).to have_css('.panel-title', text: all_items_title)
    expect(page).to have_css('.panel-title', text: search1.title)
    expect(page).to have_css('.panel-title', text: search2.title)

    check(search1.slug)

    save_page

    expect(page).to_not have_css('.category-title', text: all_items_title)
    expect(page).to_not have_css('.category-title', text: search2.title)
    expect(page).to have_css('.category-title', text: search1.title)
    expect(page).to have_css('.item-count', text: /\d+ items/i)
  end

end
