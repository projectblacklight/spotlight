require "spec_helper"

describe "Tags Administration" do
  let!(:tagging) { FactoryGirl.create(:tagging) }
  let(:curator) { FactoryGirl.create(:exhibit_curator) }
  before { login_as curator }
  describe "index" do
    it "should have tags" do
      visit spotlight.exhibit_tags_path(Spotlight::Exhibit.default)
      expect(page).to have_css("td", text: tagging.tag.name)
    end
  end
  describe "destroy" do
    it "should destroy a tag" do
      visit spotlight.exhibit_tags_path(Spotlight::Exhibit.default)
      click_link "Delete"
      expect(page).not_to have_css("td", text: tagging.tag.name)
    end
  end
end
