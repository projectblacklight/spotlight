# frozen_string_literal: true

describe 'Dashboard', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let!(:parent_feature_page) do
    FactoryBot.create(:feature_page, title: 'Parent Page', exhibit:)
  end
  let!(:child_feature_page) do
    FactoryBot.create(
      :feature_page,
      title: 'Child Page',
      parent_page: parent_feature_page,
      exhibit:
    )
  end
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit:) }

  before do
    login_as(admin)
  end

  it 'includes a list of recently edited feature pages' do
    visit spotlight.exhibit_dashboard_path(exhibit)
    expect(page).to have_text 'Recent site building activity'
    expect(page).to have_text 'Parent Page'
    expect(page).to have_text 'Child Page'
  end

  it 'includes a list of recently indexed items' do
    visit spotlight.exhibit_dashboard_path(exhibit)
    expect(page).to have_text 'Recently updated items'
    expect(page).to have_selector('#documents')
  end
end
