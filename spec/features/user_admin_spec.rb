require "spec_helper"

describe "User Administration" do
  let!(:exhibit) { Spotlight::Exhibit.default }
  let!(:user) { FactoryGirl.create(:exhibit_admin) }
  before { login_as user }
  describe "index" do
    it "should show the users for the exhibit" do
      visit spotlight.exhibit_roles_path(exhibit)
      exhibit.roles.each do |role|
        expect(page).to have_css("td", text: role.user.email)
        expect(page).to have_css("td", text: role.role.humanize)
      end
    end
  end
end
