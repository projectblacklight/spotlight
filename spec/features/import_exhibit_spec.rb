require 'spec_helper'
require 'tempfile'

describe "Allow exhibit admins to import and export content from an exhibit", :type => :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:user) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
  before { login_as user }

  it "should allow admins to export content from an exhibit" do
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    within '#user-util-collapse .dropdown-menu' do
      click_link 'Dashboard'
    end

    click_link "Import/Export"
    click_link "Export data"

    data = JSON.parse(page.body)

    expect(data).to include "title", "subtitle", "description", "searches_attributes", "home_page_attributes"

  end

  it "should allow admins to import content into an exhibit" do
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    within '#user-util-collapse .dropdown-menu' do
      click_link 'Dashboard'
    end

    click_link "Import/Export"

    file = Tempfile.new('foo')
    file.write({"title" => "A better title"}.to_json)
    file.rewind
    begin
      attach_file("file", File.expand_path(file.path))
      click_button "Import data"
    ensure
      file.close
      file.unlink
    end
    expect(page).to have_content "The exhibit was successfully updated."
    expect(page).to have_content "A better title"
  end

  it "should have breadcrumbs" do
    visit spotlight.import_exhibit_path exhibit

    expect(page).to have_breadcrumbs "Home", "Administration", "Import/Export"
  end
end
