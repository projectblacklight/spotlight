require 'spec_helper'

describe "A curator can see the items page", :type => :feature do
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator) }

  it "should work" do
    login_as exhibit_curator

    visit '/'
    within '.dropdown-menu' do
      click_link 'Dashboard'
    end
    expect(page).to have_content "Items"
  end
end
