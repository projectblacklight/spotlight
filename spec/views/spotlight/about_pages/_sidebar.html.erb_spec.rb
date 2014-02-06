require 'spec_helper'

describe "spotlight/about_pages/_sidebar.html.erb" do
  let!(:page1) { FactoryGirl.create(:about_page, title: "One", weight: 4) }
  let!(:page2) { FactoryGirl.create(:about_page, exhibit: page1.exhibit, title: "Two", published: false) }
  let!(:page3) { FactoryGirl.create(:about_page, exhibit: page1.exhibit, title: "Three") }
  
  before do
    view.stub(current_exhibit: page1.exhibit)
    view.stub(about_page_path: '/about/9')
  end

  it "renders a list of pages" do
    render
    # Checking that they are sorted accoding to weight
    expect(rendered).to have_selector "#sidebar ul.sidenav li:nth-child(1) a", text: "Three"
    expect(rendered).to have_selector "#sidebar ul.sidenav li:nth-child(2) a", text: "One"
    expect(rendered).not_to have_link "Two"
  end
end


