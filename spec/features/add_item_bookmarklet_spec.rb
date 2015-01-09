require 'spec_helper'

describe "adding an item using the provided bookmarklet", :type => :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  let(:search) { exhibit.searches.first }
  before { login_as curator }

  it "should have an exhibit-specific bookmarklet" do
    visit spotlight.admin_exhibit_catalog_index_path(exhibit)
    click_link "Add repository item"

    expect(page).to have_content "Drag this button to the bookmarks toolbar in your web browser"
    expect(page).to have_link "#{exhibit.title} - Blacklight widget"
  end

  it "should trigger the bookmarklet" do
    # magic.
  end

  it "should submit the form to create a new item" do
    allow_any_instance_of(Spotlight::Resource).to receive(:reindex)
    visit spotlight.new_exhibit_resource_path(exhibit, popup: true, resource: { url: "info:url" })
    expect(page).to have_content "Add Resource"
    expect(first('#resource_url', visible: false).value).to eq 'info:url'
    click_button "Create Resource"
    expect(Spotlight::Resource.last.url).to eq "info:url"
  end
end
