require "spec_helper"

describe "Report a Problem" do
  it "should be a header link" do
    visit catalog_index_path
    click_on "Report a problem"

    expect(page).to have_content "Report a problem"
  end

  it "should accept a problem report" do
    e = Spotlight::Exhibit.default
    e.contact_emails = ["test@example.com", "test2@example.com"]
    e.save
    
    visit catalog_index_path
    click_on "Report a problem"
    expect(find("#contact_form_current_url", visible: false).value).to end_with catalog_index_path 
    fill_in "Name", with: "Some Body"
    fill_in "Email", with: "test@example.com"
    fill_in "Message", with: "This is my problem report"

    click_on "Send"
    expect(ActionMailer::Base.deliveries).to have(1).email

  end
end
