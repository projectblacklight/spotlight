require 'spec_helper'

describe "Add and update the site masthead", :type => :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:user) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }

  before { login_as user }
  it 'should update site masthead options' do
    visit spotlight.exhibit_dashboard_path(exhibit)

    within "#sidebar" do
      click_link "Appearance"
    end

    click_link "Site masthead"

    check "Show background image in masthead"
    choose "Upload an image"

    click_button "Save changes"

    expect(page).to have_content("The appearance was successfully updated.")

    within "#sidebar" do
      click_link "Appearance"
    end

    click_link "Site masthead"

    expect(field_labeled('Show background image in masthead')).to be_checked
    expect(field_labeled('Upload an image')).to be_checked
  end
  it 'should display a masthead image when one is uploaded and configured' do
    visit spotlight.exhibit_dashboard_path(exhibit)
    expect(page).to_not have_css('#exhibit-masthead.with-image')
    within "#sidebar" do
      click_link "Appearance"
    end

    click_link "Site masthead"

    check "Show background image in masthead"

    attach_file('appearance_masthead_image', File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')));

    click_button "Save changes"

    expect(page).to have_content("The appearance was successfully updated.")

    expect(page).to have_css('#exhibit-masthead.with-image .background-container')
  end
  it 'should not display an uploaded masthead if configured to not display' do
    visit spotlight.exhibit_dashboard_path(exhibit)
    expect(page).to_not have_css('#exhibit-masthead.with-image')
    within "#sidebar" do
      click_link "Appearance"
    end

    click_link "Site masthead"

    attach_file('appearance_masthead_image', File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')));

    click_button "Save changes"

    expect(page).to have_content("The appearance was successfully updated.")

    expect(page).to_not have_css('#exhibit-masthead.with-image .background-container')
  end
end
