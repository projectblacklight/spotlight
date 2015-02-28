require 'spec_helper'

describe "Update the appearance", :type => :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:user) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }

  before { login_as user }
  it "should update appearance options" do
    visit spotlight.exhibit_dashboard_path(exhibit)
    within "#sidebar" do
      click_link "Appearance"
    end

    click_link "Exhibit style"
    uncheck "Searchable (offer searchbox and facet sidebar)"

    click_link "Search results"
    uncheck "List"

    choose "20"

    click_button "Save changes"

    expect(page).to have_content("The appearance was successfully updated.")

    within "#sidebar" do
      click_link "Appearance"
    end

    click_link "Exhibit style"
    expect(field_labeled('Searchable (offer searchbox and facet sidebar)')).to_not be_checked

    click_link "Search results"
    expect(field_labeled('List')).to_not be_checked
    expect(field_labeled('Gallery')).to be_checked

    expect(field_labeled('20')).to be_checked
    expect(field_labeled('10')).to_not be_checked
  end

  it "should hide search features when the exhibit is not searchable" do
    visit spotlight.exhibit_dashboard_path(exhibit)
    within "#sidebar" do
      click_link "Appearance"
    end

    uncheck "Searchable (offer searchbox and facet sidebar)"

    click_button "Save changes"

    visit spotlight.exhibit_root_path(exhibit)

    expect(page).to_not have_link "Saved Searches"
    expect(page).to_not have_link "History"
    expect(page).to_not have_content "Limit your search"
    expect(page).to_not have_css ".search-query-form"
  end
end
