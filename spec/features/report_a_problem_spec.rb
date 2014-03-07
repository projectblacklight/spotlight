require "spec_helper"

describe "Report a Problem" do
  let!(:exhibit) { Spotlight::ExhibitFactory.default }
  it "should be a header link" do
    visit root_path
    click_on "Report a problem"

    expect(page).to have_content "Report a problem"
  end

  describe "when emails are setup" do
    before do
      e = Spotlight::ExhibitFactory.default
      e.contact_emails_attributes= [ { "email"=>"test@example.com"}, {"email"=>"test2@example.com"}]
      e.save!
    end

    it "should accept a problem report", js: true do
      visit spotlight.exhibit_catalog_path(Spotlight::ExhibitFactory.default, id: 'dq287tq6352')
      click_on "Report a problem"
      expect(find("#contact_form_current_url", visible: false).value).to end_with spotlight.exhibit_catalog_path(Spotlight::ExhibitFactory.default, id: 'dq287tq6352') 
      fill_in "Name", with: "Some Body"
      fill_in "Email", with: "test@example.com"
      fill_in "Message", with: "This is my problem report"

      expect {
        click_on "Send"
      }.to change {ActionMailer::Base.deliveries.count}.by(1)
    end
  end
end
