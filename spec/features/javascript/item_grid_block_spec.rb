require "spec_helper"

describe "Item Grid Block", type: :feature, js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }

  before { login_as exhibit_curator }

  it "should display items that are configured to display" do
    skip("Passing locally but Travis is throwing intermittent errors") if ENV["CI"]
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    click_link "Edit"

    add_widget 'item-grid'

    within ".item-grid-admin" do
      fill_in "Heading", :with => "Feature Title"
      
      content_editable = find(".st-text-block")
      content_editable.set("zzz")

      fill_in_typeahead_field "item-grid-id_0_title", with: "dq287tq6352"
      fill_in_typeahead_field "item-grid-id_1_title", with: "jp266yb7109"
      fill_in_typeahead_field "item-grid-id_2_title", with: "zv316zr9542"

      ##
      # Dunno why this isn't working correctly:
      #   Unable to find checkbox "item-grid-display_2"
      # uncheck("item-grid-display_2")
      # instead, we use #execute_script:
      page.execute_script '
        $("[name=\'item-grid-display_2\']").prop("checked", false);

      ';
    end
    
    save_page
    
    expect(page).to have_css "h3", text: "Feature Title"
    expect(page).to have_content "zzz"
    expect(page).to have_css("[data-id='dq287tq6352']")
    expect(page).to have_css("[data-id='jp266yb7109']")
    expect(page).not_to have_css("[data-id='zv316zr9542']")
  end

end
