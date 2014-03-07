require "spec_helper"

describe "Feature page" do
  describe "sidebar" do
    let!(:exhibit) { Spotlight::ExhibitFactory.default }

    let!(:parent_feature_page) { 
      FactoryGirl.create(:feature_page, title: "Parent Page")
    }
    let!(:child_feature_page) {
      FactoryGirl.create(
        :feature_page,
        title: "Child Page",
        parent_page: parent_feature_page
      )
    }
    describe "when configured to display" do
      before { parent_feature_page.display_sidebar = true;  parent_feature_page.save }
      after  { parent_feature_page.display_sidebar = false; parent_feature_page.save }
      it "should be present" do
        visit spotlight.exhibit_feature_page_path(parent_feature_page.exhibit, parent_feature_page)
        # the sidebar should display
        within("#sidebar") do
          # the current page should be the sidebar header
          expect(page).to have_css("h4", text: parent_feature_page.title)
          # within the sidebar navigation
          within("ol.sidenav") do
            # there should be a link to the child page
            expect(page).to have_css("li a", text: child_feature_page.title)
          end
        end
      end
    end
    describe "when configured to not display" do
      before { parent_feature_page.display_sidebar = false;  parent_feature_page.save }
      it "should not be present" do
        visit spotlight.exhibit_feature_page_path(parent_feature_page.exhibit, parent_feature_page)
        expect(page).not_to have_css("#sidebar")
        expect(page).not_to have_content(child_feature_page.title)
      end
    end
  end
end
