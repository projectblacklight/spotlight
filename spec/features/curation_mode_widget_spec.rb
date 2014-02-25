require "spec_helper"

describe "Curation Mode Widget" do
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator) }
  let(:feature_page) { FactoryGirl.create(:feature_page) }
  let(:doc_id) { "dq287tq6352" }
  let(:curation_mode_link) { "Turn off." }
  let(:curation_mode_text) { "You are in curation mode. #{curation_mode_link}" }
  let(:user_mode_link) { "Enter curation mode." }
  let(:user_mode_text) { "You are in end-user mode. #{user_mode_link}" }
  describe "when not logged in" do
    describe "the feature pages" do
      describe "edit page" do
        it "should not render the widget" do
          visit spotlight.edit_polymorphic_path([feature_page.exhibit, feature_page])
          expect(page).not_to have_content(curation_mode_text)
          expect(page).not_to have_link(curation_mode_link)
        end
      end
      describe "show page" do
        it "should not render the widget" do
          visit spotlight.polymorphic_path([feature_page.exhibit, feature_page])
          expect(page).not_to have_content(curation_mode_text)
          expect(page).not_to have_link(curation_mode_link)
        end
      end
    end
  end
  describe "when logged in" do
    before {login_as exhibit_curator}
    describe "the feature pages" do
      describe "edit page" do
        it "should have text indicating that the user is in curation mode and a link to turn it off" do
          visit spotlight.edit_polymorphic_path([feature_page.exhibit, feature_page])
          expect(page).to have_content(curation_mode_text)
          expect(page).to have_link(curation_mode_link)
        end
      end
      describe "show page" do
        it "should have text indicating that the user is in end-user mode and a link to turn go into curation mode" do
          visit spotlight.polymorphic_path([feature_page.exhibit, feature_page])
          expect(page).to have_content(user_mode_text)
          expect(page).to have_link(user_mode_link)
        end
      end
    end
    describe "the spotlight catalog" do
      describe "edit page" do
        it "should have text indicating that the user is in curation mode and a link to turn it off" do
          visit spotlight.edit_exhibit_catalog_path(Spotlight::Exhibit.default, doc_id)
          expect(page).to have_content(curation_mode_text)
          expect(page).to have_link(curation_mode_link)
        end
      end
      describe "show page" do
        it "should have text indicating that the user is in end-user mode and a link to turn go into curation mode" do
          visit spotlight.exhibit_catalog_path(Spotlight::Exhibit.default, doc_id)
          expect(page).to have_content(user_mode_text)
          expect(page).to have_link(user_mode_link)
        end
      end
    end
  end
end