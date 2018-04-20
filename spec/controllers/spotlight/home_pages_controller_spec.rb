describe Spotlight::HomePagesController, type: :controller, versioning: true do
  routes { Spotlight::Engine.routes }
  let(:valid_attributes) { { 'title' => 'MyString', thumbnail: { iiif_url: '' } } }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:page) { exhibit.home_page }

  describe 'when signed in as a curator' do
    let(:user) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
    before do
      sign_in user
    end

    describe 'GET edit' do
      describe "when the page title isn't set" do
        before do
          page.title = nil
        end

        it 'shows breadcrumbs' do
          expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_root_path(exhibit))
          expect(controller).to receive(:add_breadcrumb).with('Feature pages', exhibit_feature_pages_path(exhibit))
          expect(controller).to receive(:add_breadcrumb).with('Exhibit Home', [:edit, exhibit, page])
          get :edit, params: { id: page, exhibit_id: page.exhibit }
          expect(response).to be_successful
        end
      end
      it 'shows breadcrumbs' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_root_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Feature pages', exhibit_feature_pages_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with(page.title, [:edit, exhibit, page])
        get :edit, params: { id: page, exhibit_id: page.exhibit }
        expect(response).to be_successful
      end
    end
    describe 'PUT update' do
      it 'redirects to the feature page index action' do
        put :update, params: { id: page, exhibit_id: page.exhibit.id, home_page: valid_attributes }
        page.reload
        expect(response).to redirect_to(exhibit_home_page_path(page.exhibit, page))
        expect(flash[:notice]).to have_link 'Undo changes'
      end
    end
  end

  describe 'GET show' do
    it 'gets search results for display facets' do
      allow(controller).to receive_messages(search_results: [double, double])
      get :show, params: { exhibit_id: exhibit }
      expect(assigns[:response]).to_not be_blank
      expect(assigns[:document_list]).to_not be_blank
      expect(assigns[:page]).to eq exhibit.home_page
    end
    it 'does not render breadcrumbs' do
      expect(controller).not_to receive(:add_breadcrumb)
      allow(controller).to receive_messages(search_results: [double, double])
      get :show, params: { exhibit_id: exhibit }
      expect(response).to be_successful
    end
    it 'does not do the search when the sidebar is hidden' do
      page.display_sidebar = false
      page.save
      allow(controller).to receive_messages(search_results: [double, double])
      get :show, params: { exhibit_id: exhibit }
      expect(assigns).not_to have_key :response
      expect(assigns).not_to have_key :document_list
    end

    context 'when a non-default locale version of the page exists' do
      let!(:page) { exhibit.home_page }
      let!(:page_es) { FactoryBot.create(:home_page, exhibit: exhibit, locale: 'es') }

      it 'is loaded' do
        get :show, params: { exhibit_id: exhibit, locale: 'es' }
        expect(assigns[:page]).to eq page_es
      end
    end

    context 'when the exhibit is not published' do
      before do
        exhibit.update(published: false)
      end

      it 'redirects an anonymous user to the signin path' do
        get :show, params: { exhibit_id: exhibit }
        expect(response).to redirect_to(main_app.new_user_session_path)
      end

      it 'redirects an unauthorized user to the signin path' do
        user = FactoryBot.create(:exhibit_curator)
        sign_in user
        expect do
          get :show, params: { exhibit_id: exhibit }
        end.to raise_error ActionController::RoutingError
      end

      it 'redirects an authorized user to the signin path' do
        user = FactoryBot.create(:exhibit_curator, exhibit: exhibit)
        sign_in user
        get :show, params: { exhibit_id: exhibit }
        expect(response).to be_successful
      end
    end
  end

  describe 'GET clone' do
    let(:user) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
    let(:page) { exhibit.home_page }

    before { sign_in user }

    it 'calls the CloneTranslatedPageFromLocale service' do
      expect(
        Spotlight::CloneTranslatedPageFromLocale
      ).to receive(:call).with(locale: 'es', page: page).and_call_original

      get :clone, params: { exhibit_id: exhibit.id, id: page.id, language: 'es' }
    end
  end
end
