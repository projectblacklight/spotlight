# frozen_string_literal: true

describe 'Alt text dashboard', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:curator) { FactoryBot.create(:exhibit_curator, exhibit:) }

  before do
    FactoryBot.create(:about_page, exhibit:,
                                   content: "{\"data\":[{\"type\":\"solr_documents\",\"data\":{\"show-primary-caption\":\"false\",
                                            \"primary-caption-field\":\"\",\"show-secondary-caption\":\"false\",\"secondary-caption-field\":\"\",
                                            \"format\":\"html\",\"item\":{\"item_0\":{ \"alt_text_backup\":\"\",\"alt_text\":\"\"},
                                            \"item_2\":{\"alt_text_backup\":\"has alt\",\"alt_text\":\"has alt\"},
                                            \"item_3\":{\"decorative\":\"on\",\"alt_text_backup\":\"\"}}}}]}")
    FactoryBot.create(:feature_page, exhibit:, content: "{\"data\":[{\"type\":\"solr_documents\",\"data\":{\"show-primary-caption\":\"false\",
                                                          \"primary-caption-field\":\"\",\"show-secondary-caption\":\"false\",\"secondary-caption-field\":\"\",
                                                          \"format\":\"html\",\"item\":{}}}, {\"type\":\"block\",\"data\":{\"show-primary-caption\":\"false\",
                                                          \"primary-caption-field\":\"\",\"show-secondary-caption\":\"false\",\"secondary-caption-field\":\"\",
                                                          \"format\":\"html\",\"item\":{\"item_0\":{ \"alt_text_backup\":\"\",\"alt_text\":\"\"}}}}]}")
    login_as curator
  end

  describe 'alt_text dashboard' do
    it 'filters pages and gets alt_text totals' do
      visit spotlight.exhibit_alt_text_path(exhibit.id)
      expect(page).to have_text '2 of 3 have entered alt text'
      expect(page.all('.alt-text-status').count).to be 2
      expect(page).to have_css('.bi-exclamation-triangle-fill', count: 1)
      expect(page).to have_css('.bi-check-circle-fill', count: 1)
    end
  end
end
