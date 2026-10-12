# frozen_string_literal: true

RSpec.describe 'Translations administration', type: :request do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit:) }
  let(:page) { Capybara.string(response.body) }

  before do
    FactoryBot.create(:language, exhibit:, locale: 'fr')
    sign_in admin
  end

  describe 'GET edit' do
    it 'has a text input for each configured metadata, search, facet, and sort field' do
      get spotlight.edit_exhibit_translations_path(exhibit, language: 'fr')

      expect(page.find_by_id('metadata')).to have_field(type: 'text', count: 17)
      expect(page.find('#search_fields .translation-field-based-search-fields')).to have_field(type: 'text', count: 3)
      expect(page.find('#search_fields .translation-facet-fields')).to have_field(type: 'text', count: 7)
      expect(page.find('#search_fields .translation-sort-fields')).to have_field(type: 'text', count: 6)
    end

    context 'with exhibit-specific fields' do
      before { FactoryBot.create(:custom_field, exhibit:) }

      it 'has a text input for each exhibit-specific field' do
        get spotlight.edit_exhibit_translations_path(exhibit, language: 'fr')

        expect(page.find_by_id('metadata')).to have_field(type: 'text', count: 18)
        expect(page.find('#metadata .translation-exhibit-specific-fields')).to have_field(type: 'text', count: 1)
      end
    end

    context 'with browse categories and groups' do
      before do
        FactoryBot.create(:search, exhibit:, title: 'Browse Category 1')
        FactoryBot.create(:group, exhibit:, title: 'Browse Group 1')
        FactoryBot.create(:group, exhibit:, title: 'Browse Group 2')
      end

      it 'has a title and description for every browse category, and a title for every browse group' do
        get spotlight.edit_exhibit_translations_path(exhibit, language: 'fr')

        browse = page.find_by_id('browse')
        expect(browse).to have_field(type: 'text', count: 4)
        expect(browse).to have_css('textarea', count: 2)
        expect(browse).to have_field 'All exhibit items'
        expect(browse).to have_field 'Browse Category 1'
        expect(browse).to have_css('.form-text', text: 'All items in this exhibit.')

        groups = page.find_by_id('groups')
        expect(groups).to have_field(type: 'text', count: 2)
        expect(groups).to have_field 'Browse Group 1'
        expect(groups).to have_field 'Browse Group 2'
      end
    end
  end
end
