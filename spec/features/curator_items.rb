require 'spec_helper'

describe 'A curator can see the items page', type: :feature do
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator) }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  it 'works' do
    login_as exhibit_curator
    visit spotlight.exhibit_dashboard_path(exhibit)

    expect(page).to have_content 'Items'
  end
end
