require 'spec_helper'

describe "spotlight/feature_pages/_sidebar.html.erb" do
  let!(:parent1) { FactoryGirl.create(:feature_page, exhibit: Spotlight::Exhibit.default, title: "Parent Page") }
  let!(:parent2) { FactoryGirl.create(:feature_page, exhibit: parent1.exhibit, title: "Two") }
  let!(:child1) { FactoryGirl.create(:feature_page, exhibit: parent1.exhibit, parent_page: parent1, title: "Three", weight: 4) }
  let!(:child2) { FactoryGirl.create(:feature_page, exhibit: parent1.exhibit, parent_page: parent2, title: "Four") }
  let!(:child3) { FactoryGirl.create(:feature_page, exhibit: parent1.exhibit, parent_page: parent1, title: "Five", weight: 2) }
  let!(:child4) { FactoryGirl.create(:feature_page, exhibit: parent1.exhibit, parent_page: parent1, title: "Six", published: false) }
  
  before do
    view.stub(current_exhibit: parent1.exhibit)
    view.stub(feature_page_path: '/feature/9')
  end

  it "renders a list of pages for a parent page" do
    assign(:page, parent1)
    render
    # Checking that they are sorted accoding to weight
    expect(rendered).to have_selector "h4", text: "Parent Page"
    expect(rendered).to have_selector "#sidebar ul.sidenav li:nth-child(1) a", text: "Five"
    expect(rendered).to have_selector "#sidebar ul.sidenav li:nth-child(2) a", text: "Three"
    expect(rendered).not_to have_content "Two" # not selected page
    expect(rendered).not_to have_link "Four" # different parent
    expect(rendered).not_to have_link "Six" # not published 
  end

  it "renders a list of pages from a child page" do
    assign(:page, child1)
    render
    # Checking that they are sorted accoding to weight
    expect(rendered).to have_selector "h4", text: "Parent Page"
    expect(rendered).to have_selector "#sidebar ul.sidenav li:nth-child(1) a", text: "Five"
    expect(rendered).to have_selector "#sidebar ul.sidenav li:nth-child(2) a", text: "Three"
    expect(rendered).not_to have_content "Two" # not selected page
    expect(rendered).not_to have_link "Four" # different parent
    expect(rendered).not_to have_link "Six" # not published 
  end
end


