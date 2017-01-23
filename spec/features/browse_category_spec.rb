feature 'Browse pages' do
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  context 'a browse page' do
    let!(:search) { FactoryGirl.create(:search, title: 'Some Saved Search', exhibit: exhibit, published: true) }

    let(:mock_response) { Blacklight::Solr::Response.new({ response: { numFound: 10, docs: mock_documents } }, {}) }
    let(:mock_documents) { [] }
    before do
      allow_any_instance_of(Spotlight::BrowseController).to receive(:search_results).and_return([mock_response, mock_documents])
    end

    context 'with the standard exhibit masthead' do
      it 'includes the search title and resource count in the body' do
        visit spotlight.exhibit_browse_path(exhibit, search)

        within '#main-container' do
          expect(page).to have_selector 'h1', text: 'Some Saved Search'
        end

        expect(page).not_to have_selector '.masthead .h1', text: 'Some Saved Search'
      end

      it 'shows the search bar' do
        visit spotlight.exhibit_browse_path(exhibit, search)

        expect(page).to have_selector '.search-query-form'
      end

      it 'has breadcrumbs' do
        visit spotlight.exhibit_browse_path(exhibit, search)

        expect(page).to have_selector '.breadcrumbs-container'
      end
    end

    context 'with a custom masthead' do
      let(:masthead) { FactoryGirl.create(:masthead, display: true, iiif_url: 'http://test.host/images/1') }

      before do
        search.masthead = masthead
        search.save!
      end

      it 'has a contextual masthead with the title and resource count' do
        visit spotlight.exhibit_browse_path(exhibit, search)

        expect(page).to have_selector '.masthead .h1', text: 'Some Saved Search'

        within '#main-container' do
          expect(page).not_to have_selector 'h1', text: 'Some Saved Search'
        end

        expect(page).to have_selector '.masthead small.item-count', text: /\d+ items/
      end

      it 'does not show the search bar' do
        visit spotlight.exhibit_browse_path(exhibit, search)

        expect(page).not_to have_selector '.search-query-form'
      end

      it 'does not have breadcrumbs' do
        visit spotlight.exhibit_browse_path(exhibit, search)

        expect(page).not_to have_selector '.breadcrumbs-container'
      end
    end

    context 'without a curator-selected view' do
      it 'renders the gallery view' do
        visit spotlight.exhibit_browse_path(exhibit, search)
        expect(page).to have_selector '.view-type-gallery.active'
        expect(page).to have_selector '#documents.gallery'
      end
    end

    context 'with a curator-selected default view' do
      before do
        search.update(default_index_view_type: 'list')
      end

      it 'renders the selected view' do
        visit spotlight.exhibit_browse_path(exhibit, search)
        expect(page).to have_selector '.view-type-list.active'
        expect(page).to have_selector '#documents.documents-list'
      end
    end

    it 'has <meta> tags' do
      TopHat.current['twitter_card'] = nil
      TopHat.current['opengraph'] = nil

      visit spotlight.exhibit_browse_path(exhibit, search)

      expect(page).to have_css "meta[name='twitter:title'][value='#{search.title}']", visible: false
      expect(page).to have_css "meta[property='og:site_name']", visible: false
      expect(page).to have_css "meta[property='og:title'][content='#{search.title}']", visible: false
    end
  end
end
