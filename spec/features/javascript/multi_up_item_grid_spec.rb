require "spec_helper"

describe "Mutli-Up Item Grid", js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  let!(:feature_page) { FactoryGirl.create(:feature_page, exhibit: exhibit) }
  before { login_as exhibit_curator }

  it "should display items that are configured to display (and hide items that are not)" do
    pending("Passing locally but Travis is throwing intermittent errors") if ENV["CI"]
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    click_link exhibit_curator.email
    within '#user-util-collapse .dropdown' do
      click_link 'Dashboard'
    end
    click_link "Feature pages"

    within("[data-id='#{feature_page.id}']") do
      click_link "Edit"
    end

    find("[data-icon='add']").click

    find("a[data-type='multi-up-item-grid']").click

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

    click_button "Save changes"
    expect(page).to have_content("The feature page was successfully updated.")

    visit spotlight.exhibit_feature_page_path(exhibit, feature_page)

    expect(page).to have_css("[data-id='dq287tq6352']")
    expect(page).to have_css("[data-id='jp266yb7109']")
    expect(page).not_to have_css("[data-id='zv316zr9542']")
  end

  it "should serialize the unchecked display checkboxes" do
    pending("Passing locally but Travis is throwing intermittent errors") if ENV["CI"]
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    click_link exhibit_curator.email
    within '#user-util-collapse .dropdown' do
      click_link 'Dashboard'
    end
    click_link "Feature pages"

    within("[data-id='#{feature_page.id}']") do
      click_link "Edit"
    end

    find("[data-icon='add']").click

    find("a[data-type='multi-up-item-grid']").click

    fill_in_typeahead_field "item-grid-id_0_title", with: "dq287tq6352"
    fill_in_typeahead_field "item-grid-id_1_title", with: "jp266yb7109"
    fill_in_typeahead_field "item-grid-id_2_title", with: "zv316zr9542"


    click_button "Save changes"
    expect(page).to have_content("The feature page was successfully updated.")

    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)
    
    ##
    # Dunno why this isn't working correctly:
    #   Unable to find checkbox "item-grid-display_2"
    # uncheck("item-grid-display_2")
    # instead, we use #execute_script:
    page.execute_script '
      $("[name=\'item-grid-display_2\']").prop("checked", false);

    ';
    
    click_button "Save changes"
    expect(page).to have_content("The feature page was successfully updated.")

    expect(page).to have_css("[data-id='dq287tq6352']")
    expect(page).to have_css("[data-id='jp266yb7109']")
    expect(page).to_not have_css("[data-id='zv316zr9542']")
  end
  
  it "should optionally show the configured captions" do
    pending("Passing locally but Travis is throwing intermittent errors") if ENV["CI"]
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    click_link exhibit_curator.email
    within '#user-util-collapse .dropdown' do
      click_link 'Dashboard'
    end
    click_link "Feature pages"

    within("[data-id='#{feature_page.id}']") do
      click_link "Edit"
    end

    find("[data-icon='add']").click

    find("a[data-type='multi-up-item-grid']").click

    fill_in_typeahead_field "item-grid-id_0_title", with: "gk446cj2442"

    within('.primary-caption') do
      check("Primary caption")
      select("Title", from: 'item-grid-primary-caption-field')
    end
    within('.secondary-caption') do
      check("Secondary caption")
      select("Language", from: 'item-grid-secondary-caption-field')
    end

    click_button "Save changes"

    expect(page).to have_content("The feature page was successfully updated.")

    visit spotlight.exhibit_feature_page_path(exhibit, feature_page)

    expect(page).to have_css(".caption", text: "[World map]")
    expect(page).to have_css(".caption", text: "Latin")
  end
end
