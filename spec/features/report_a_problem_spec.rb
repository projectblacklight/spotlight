require "spec_helper"

describe "Report a Problem", :type => :feature do
  let!(:exhibit) { FactoryGirl.create(:exhibit) }
  it "should not have a header link" do
    visit root_path
    expect(page).to_not have_content "Feedback"
  end

  describe "when emails are setup" do
    before do
      exhibit.contact_emails_attributes= [ { "email"=>"test@example.com"}, {"email"=>"test2@example.com"}]
      exhibit.save!
      exhibit.contact_emails.first.confirm!
    end

    it "should accept a problem report", js: true do
      visit spotlight.exhibit_catalog_path(exhibit, id: 'dq287tq6352')
      click_on "Feedback"
      expect(find("#contact_form_current_url", visible: false).value).to end_with spotlight.exhibit_catalog_path(exhibit, id: 'dq287tq6352') 
      fill_in "Name", with: "Some Body"
      fill_in "Email", with: "test@example.com"
      fill_in "Message", with: "This is my problem report"

      expect {
        click_on "Send"
      }.to change {ActionMailer::Base.deliveries.count}.by(1)
    end
  end
end
