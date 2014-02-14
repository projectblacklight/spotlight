require 'spec_helper'

describe "Adding custom metadata fields", type: :feature do

  let(:admin) { FactoryGirl.create(:exhibit_admin) }
  before do
    login_as(admin)
  end

  it "should work" do
    # Add 
    
    visit spotlight.exhibit_edit_metadata_path Spotlight::Exhibit.default
    click_on "Add new field"
    fill_in "Label", with: "My new custom field"
    fill_in "Short description", with: "Helps to remind me what this field is for"

    click_on "Save"

    expect(page).to have_content "Custom field was created"
    within "#exhibit-specific-fields" do
      expect(page).to have_selector ".field-label", text: "My new custom field"
      expect(page).to have_selector ".field-description", text: "Helps to remind me what this field is for"
      # Edit
      click_link "Edit"
    end

    # on the edit form
    expect(find_field('Label').value).to eq 'My new custom field'
    expect(find_field('Short description').value).to eq 'Helps to remind me what this field is for'
    fill_in 'Short description', with: 'A much better description'

    click_button "Save changes"

    expect(page).to have_content "Custom field was updated"

    within "#exhibit-specific-fields" do
      expect(page).to have_selector ".field-label", text: "My new custom field"
      expect(page).to have_selector ".field-description", text: "A much better description"
      # Destroy 
      click_link "Delete"
    end

    expect(page).to have_content "Custom field was deleted"
    
  end
end
