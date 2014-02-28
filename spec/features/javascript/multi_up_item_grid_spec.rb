require "spec_helper"

describe "Mutli-Up Item Grid", js: true do
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator) }
  let!(:exhibit) { Spotlight::Exhibit.default }
  let!(:feature_page) { FactoryGirl.create(:feature_page, exhibit: exhibit) }
  before { login_as exhibit_curator }
  it "should display items that are configured to display (and hide items that are not)" do
    pending("Passing locally but Travis is thowing intermittent errors") if ENV["CI"]
    visit '/'
    click_link exhibit_curator.email
    within '.dropdown-menu' do
      click_link 'Dashboard'
    end
    click_link "Feature pages"

    within("[data-id='#{feature_page.id}']") do
      click_link "Edit"
    end

    find("[data-icon='add']").click

    find("a[data-type='multi-up-item-grid']").click

    # Poltergeist / Capybara doesn't fire the events typeahead.js
    # is listening for, so we help it out a little:
    fill_in("item-grid-id_0_title", with: "dq287tq6352")
    page.execute_script '
      $("input[name=\'item-grid-id_0_title\']").val("dq287tq6352").keydown();
      $("input[name=\'item-grid-id_0_title\']").typeahead("open");
      $(".tt-suggestion").click();
    ';
    find('.tt-suggestion').click
 
    fill_in("item-grid-id_1_title", with: "jp266yb7109")
    page.execute_script '
      $("input[name=\'item-grid-id_1_title\']").val("jp266yb7109").keydown();
      $("input[name=\'item-grid-id_1_title\']").typeahead("open");
      $(".tt-suggestion").click();
    ';
    find('.tt-suggestion').click

    fill_in("item-grid-id_2_title", with: "zv316zr9542")
    page.execute_script '
      $("input[name=\'item-grid-id_2_title\']").val("zv316zr9542").keydown();
      $("input[name=\'item-grid-id_2_title\']").typeahead("open");
      $(".tt-suggestion").click();
    ';
    find('.tt-suggestion').click


    ##
    # Dunno why this isn't working correctly:
    #   Unable to find checkbox "item-grid-display_2"
    # uncheck("item-grid-display_2")
    # instead, we use #execute_script:
    page.execute_script '
      $("[name=\'item-grid-display_2\']").prop("checked", false);

    ';

    click_button "Save changes"
    expect(page).to have_content("Page was successfully updated.")

    visit spotlight.exhibit_feature_page_path(exhibit, feature_page)

    expect(page).to have_css("[data-id='dq287tq6352']")
    expect(page).to have_css("[data-id='jp266yb7109']")
    expect(page).not_to have_css("[data-id='zv316zr9542']")
  end
  it "should optionally show the configured caption" do
    pending("Passing locally but Travis is thowing intermittent errors") if ENV["CI"]
    visit '/'
    click_link exhibit_curator.email
    within '.dropdown-menu' do
      click_link 'Dashboard'
    end
    click_link "Feature pages"

    within("[data-id='#{feature_page.id}']") do
      click_link "Edit"
    end

    find("[data-icon='add']").click

    find("a[data-type='multi-up-item-grid']").click

    # Poltergeist / Capybara doesn't fire the events typeahead.js
    # is listening for, so we help it out a little:
    fill_in("item-grid-id_0_title", with: "gk446cj2442")
    page.execute_script '
      $("input[name=\'item-grid-id_0_title\']").val("gk446cj2442").keydown();
      $("input[name=\'item-grid-id_0_title\']").typeahead("open");
      $(".tt-suggestion").click();
    ';
    find('.tt-suggestion').click

    check("Display caption")
    select("Language", from: "Caption field")

    click_button "Save changes"

    expect(page).to have_content("Page was successfully updated.")

    visit spotlight.exhibit_feature_page_path(exhibit, feature_page)

    expect(page).to have_css(".caption", text: "Latin")
  end
end