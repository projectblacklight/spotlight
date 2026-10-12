# frozen_string_literal: true

RSpec.describe 'Curation pages', type: :request do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:page) { Capybara.string(response.body) }

  before { sign_in user }

  describe 'the exhibit dashboard' do
    let(:user) { FactoryBot.create(:exhibit_admin, exhibit:) }
    let!(:parent_feature_page) { FactoryBot.create(:feature_page, title: 'Parent Page', exhibit:) }

    before { FactoryBot.create(:feature_page, title: 'Child Page', parent_page: parent_feature_page, exhibit:) }

    it 'includes recently edited feature pages and recently indexed items' do
      get spotlight.exhibit_dashboard_path(exhibit)

      expect(page).to have_text 'Recent site building activity'
      expect(page).to have_text 'Parent Page'
      expect(page).to have_text 'Child Page'

      expect(page).to have_text 'Recently updated items'
      expect(page).to have_css('#documents')
    end
  end

  describe 'the about pages list' do
    let(:user) { FactoryBot.create(:exhibit_curator, exhibit:) }

    before do
      FactoryBot.create(:about_page, exhibit:)
      FactoryBot.create(:about_page, exhibit:, title: 'A new one')
    end

    it 'shows the about pages to be curated' do
      get spotlight.exhibit_about_pages_path(exhibit)

      expect(page).to have_text 'A new one'
    end
  end

  describe 'the metadata configuration page' do
    let(:user) { FactoryBot.create(:exhibit_admin, exhibit:) }

    it 'lists the metadata fields' do
      get spotlight.edit_exhibit_metadata_configuration_path(exhibit)

      expect(page).to have_css('h1 small', text: 'Metadata')
      expect(page.find("[data-id='language_ssm']")).to have_css('td', text: 'Language')
    end
  end
end
