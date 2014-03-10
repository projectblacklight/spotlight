require 'spec_helper'

describe "Dashboard" do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:admin) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
  before do
    login_as(admin)
  end

  let!(:parent_feature_page) { 
    FactoryGirl.create(:feature_page, title: "Parent Page", exhibit: exhibit)
  }
  let!(:child_feature_page) {
    FactoryGirl.create(
      :feature_page,
      title: "Child Page",
      parent_page: parent_feature_page,
      exhibit: exhibit
    )
  }

  it "should include a list of recently edited feature pages" do
    visit spotlight.exhibit_dashboard_path(exhibit)
    expect(page).to have_content "Recent Site Building Activity"
    expect(page).to have_content "Parent Page"
    expect(page).to have_content "Child Page"
  end

  it "should include a list of recently indexed items" do
    visit spotlight.exhibit_dashboard_path(exhibit)
    expect(page).to have_content "Recently Updated Items"
    expect(page).to have_selector("#documents")
  end

end
