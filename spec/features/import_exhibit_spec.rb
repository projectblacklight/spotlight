require 'spec_helper'
require 'tempfile'

describe "Allow exhibit admins to import and export content from an exhibit" do
  let(:user) { FactoryGirl.create(:exhibit_admin) }
  let(:exhibit) { Spotlight::Exhibit.default }
  before {login_as user}

  it "should allow admins to export content from an exhibit" do
    visit '/'
    within '.dropdown-menu' do
      click_link 'Dashboard'
    end

    click_link "Settings"
    click_link "Export"

    data = JSON.parse(page.body)

    expect(data).to include "title", "subtitle", "description", "searches_attributes", "home_page_attributes"

  end

  it "should allow admins to import content into an exhibit" do
    visit '/'
    within '.dropdown-menu' do
      click_link 'Dashboard'
    end

    click_link "Settings"
    click_link "Import"

    file = Tempfile.new('foo')
    file.write({"title" => "A better title"}.to_json)
    file.rewind
    begin
      attach_file("file", File.expand_path(file.path))
      click_button "Save"
    ensure
      file.close
      file.unlink
    end
    expect(page).to have_content "The exhibit was successfully updated."
    expect(page).to have_content "A better title"
  end
end
