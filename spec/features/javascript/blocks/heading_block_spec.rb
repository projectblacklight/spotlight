# frozen_string_literal: true

RSpec.feature 'Heading block', :js do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }
  let!(:feature_page) { FactoryBot.create(:feature_page, exhibit:) }

  before do
    login_as exhibit_curator

    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)
  end

  describe 'accessibility' do
    context 'when used in isolation' do
      it 'is accessible' do
        add_widget 'heading'
        find('.st-text-block.st-text-block--heading').set('My Feature Page Heading')

        save_page_changes

        expect(page).to have_text('My Feature Page Heading')
        expect(page).to be_axe_clean.within '#content'
      end
    end

    context 'when combined with other blocks that render headings' do
      it 'is accessible' do
        pending 'heading updates from https://github.com/projectblacklight/spotlight/issues/3535'

        add_widget 'heading'
        find('.st-text-block.st-text-block--heading').set('My Feature Page Heading')

        add_widget 'solr_documents_embed'
        fill_in_solr_document_block_typeahead_field with: 'dq287tq6352'
        fill_in 'Heading', with: 'Embed Heading'

        save_page_changes

        expect(page).to have_text('My Feature Page Heading')
        expect(page).to be_axe_clean.within '#content'
      end
    end
  end
end
