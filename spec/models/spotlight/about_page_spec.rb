# frozen_string_literal: true

RSpec.describe Spotlight::AboutPage, type: :model do
  let(:page) { described_class.create! exhibit: FactoryBot.create(:exhibit) }

  it { is_expected.not_to be_feature_page }
  it { is_expected.to be_about_page }

  it 'displays the sidebar' do
    expect(page).to be_display_sidebar
  end

  it 'forces the sidebar to display (we do not provide an interface for setting this to false)' do
    expect(page).to be_display_sidebar
    page.display_sidebar = false
    page.save
    expect(page).to be_display_sidebar
  end
end
