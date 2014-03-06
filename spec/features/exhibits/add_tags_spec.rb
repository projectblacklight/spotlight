require 'spec_helper'

describe "Add tags to an item in an exhibit" do
  let(:curator) { FactoryGirl.create(:exhibit_curator) }
  let(:custom_field) { FactoryGirl.create(:custom_field) }

  before do
    login_as(curator)
  end

  it "should change and display the of tags" do
    visit spotlight.exhibit_catalog_path(Spotlight::ExhibitFactory.default, "dq287tq6352")

    expect(page).to have_link "Edit"

    click_on "Edit"

    fill_in "Tags", with: "One, Two and a half, Three"

    click_on "Save changes"

    visit spotlight.exhibit_catalog_path(Spotlight::ExhibitFactory.default, "dq287tq6352")

    within("ul.tags") do
      expect(page).to have_selector  "li", text: "One"
      expect(page).to have_selector  "li", text: "Two and a half"
      expect(page).to have_selector  "li", text: "Three"
    end

    click_on "Two and a half"

    expect(page).to have_content "Remove constraint Exhibit Tags: Two and a half"
  end
end

