describe 'A curator can see the items page', type: :feature do
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator) }
  let(:exhibit) { FactoryBot.create(:exhibit) }

  it 'works' do
    login_as exhibit_curator
    visit spotlight.exhibit_dashboard_path(exhibit)
    expect(page).to have_content 'Items'
  end
end
