require 'spec_helper'

describe "Update the appearance" do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:user) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }

  before { login_as user }
  it "should update appearance options" do
    visit spotlight.exhibit_dashboard_path(exhibit)
    within "#sidebar" do
      click_link "Appearance"
    end

    uncheck "List"

    choose "20"

    choose "Large"

    # #feild_labeled doesn't appear to work for disabled inputs
    expect(page).to have_css("input[name='appearance[sort_fields][relevance]'][disabled='disabled']")
    uncheck "Title"
    uncheck "Identifier"

    click_button "Save changes"

    expect(page).to have_content("The appearance was successfully updated.")

    within "#sidebar" do
      click_link "Appearance"
    end

    expect(field_labeled('List')).to_not be_checked
    expect(field_labeled('Gallery')).to be_checked

    expect(field_labeled('20')).to be_checked
    expect(field_labeled('10')).to_not be_checked

    expect(field_labeled('Large')).to be_checked

    # #feild_labeled doesn't appear to work for disabled inputs
    expect(page).to have_css("input[name='appearance[sort_fields][relevance]'][disabled='disabled']")
    expect(field_labeled('Type')).to be_checked
    expect(field_labeled('Date')).to be_checked
    expect(field_labeled('Title')).to_not be_checked
    expect(field_labeled('Identifier')).to_not be_checked

  end
end
