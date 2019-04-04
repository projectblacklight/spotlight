# frozen_string_literal: true

describe 'Dashboard', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }
  before do
    login_as(admin)
  end

  let!(:parent_feature_page) do
    FactoryBot.create(:feature_page, title: 'Parent Page', exhibit: exhibit)
  end
  let!(:child_feature_page) do
    FactoryBot.create(
      :feature_page,
      title: 'Child Page',
      parent_page: parent_feature_page,
      exhibit: exhibit
    )
  end

  it 'includes a list of recently edited feature pages' do
    visit spotlight.exhibit_dashboard_path(exhibit)
    expect(page).to have_content 'Recent Site Building Activity'
    expect(page).to have_content 'Parent Page'
    expect(page).to have_content 'Child Page'
  end

  it 'includes a list of recently indexed items' do
    visit spotlight.exhibit_dashboard_path(exhibit)
    expect(page).to have_content 'Recently Updated Items'
    expect(page).to have_selector('#documents')
  end
end
