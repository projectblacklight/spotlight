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

    uncheck "Searchable (offer searchbox and facet sidebar)"

    uncheck "List"

    choose "20"

    # #feild_labeled doesn't appear to work for disabled inputs
    expect(page).to have_css("input[name='appearance[sort_fields][relevance][enable]'][disabled='disabled']")
    expect(page).to have_css("#nested-sort-fields .dd-item:nth-child(5) h3", text: "Identifier")

    uncheck "appearance_sort_fields_title_enabled"
    uncheck "appearance_sort_fields_identifier_enabled"

    find("#appearance_sort_fields_type_weight").set("100")

    click_button "Save changes"

    expect(page).to have_content("The appearance was successfully updated.")

    within "#sidebar" do
      click_link "Appearance"
    end

    expect(field_labeled('Searchable (offer searchbox and facet sidebar)')).to_not be_checked

    expect(field_labeled('List')).to_not be_checked
    expect(field_labeled('Gallery')).to be_checked

    expect(field_labeled('20')).to be_checked
    expect(field_labeled('10')).to_not be_checked

    # #feild_labeled doesn't appear to work for disabled inputs
    expect(page).to have_css("input[name='appearance[sort_fields][relevance][enable]'][disabled='disabled']")
    expect(find("#appearance_sort_fields_type_enabled")).to be_checked
    expect(find("#appearance_sort_fields_date_enabled")).to be_checked
    expect(find("#appearance_sort_fields_title_enabled")).to_not be_checked
    expect(find("#appearance_sort_fields_identifier_enabled")).to_not be_checked

    # Type is now sorted last
    expect(page).to have_css("#nested-sort-fields .dd-item:nth-child(5) h3", text: "Type")
  end
end
