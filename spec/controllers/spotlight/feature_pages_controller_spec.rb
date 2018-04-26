describe Spotlight::FeaturePagesController, type: :controller, versioning: true do
  routes { Spotlight::Engine.routes }

  describe 'when not logged in' do
    let(:exhibit) { FactoryBot.create(:exhibit) }
    describe 'GET clone' do
      let(:page) { FactoryBot.create(:feature_page, exhibit: exhibit) }

      it 'is not allowed' do
        get :clone, params: { exhibit_id: exhibit.id, id: page.id, language: 'es' }
        expect(flash['alert']).to eq 'You need to sign in or sign up before continuing.'
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  # This should return the minimal set of attributes required to create a valid
  # Page. As you add validations to Page, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { 'title' => 'MyString', thumbnail_attributes: { iiif_url: '' } } }
  describe 'when signed in as a curator' do
    let(:exhibit) { FactoryBot.create(:exhibit) }
    let(:user) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
    before { sign_in user }

    describe 'GET index' do
      let!(:page) { FactoryBot.create(:feature_page, exhibit: exhibit) }
      it 'assigns all feature pages as @pages' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_root_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Curation', exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Feature pages', exhibit_feature_pages_path(exhibit))
        get :index, params: { exhibit_id: exhibit }
        expect(assigns(:pages)).to include page
        expect(assigns(:exhibit)).to eq exhibit
      end
    end

    describe 'GET show' do
      describe 'on a top level page' do
        let(:page) { FactoryBot.create(:feature_page, exhibit: exhibit) }
        it 'assigns the requested page as @page' do
          expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_root_path(exhibit))
          expect(controller).to receive(:add_breadcrumb).with(page.title, [exhibit, page])
          get :show, params: { exhibit_id: page.exhibit.id, id: page }
          expect(assigns(:page)).to eq(page)
        end
      end
      describe 'on a sub-page' do
        let(:page) { FactoryBot.create(:feature_subpage, exhibit: exhibit) }
        it 'assigns the requested page as @page' do
          expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_root_path(exhibit))
          expect(controller).to receive(:add_breadcrumb).with(page.parent_page.title, [exhibit, page.parent_page])
          expect(controller).to receive(:add_breadcrumb).with(page.title, [exhibit, page])
          get :show, params: { exhibit_id: page.exhibit, id: page }
          expect(assigns(:page)).to eq(page)
        end
      end

      describe 'when "switching" locales for pages that have updated their title/slug' do
        let(:page) { FactoryBot.create(:feature_page, exhibit: exhibit) }
        let!(:page_es) do
          FactoryBot.create(
            :feature_page,
            exhibit: exhibit,
            title: 'Page in spanish',
            locale: 'es',
            default_locale_page: page
          )
        end

        it 'redirects from the spanish slug to the english page when the english locale is selected' do
          expect(page_es.slug).not_to eq page.slug # Ensure the slugs are different
          get :show, params: { exhibit_id: exhibit.id, id: page_es.slug, locale: 'en' }
          expect(response).to redirect_to(exhibit_feature_page_path(exhibit, page))
        end

        it 'redirects from the english slug to the spanish page when the spanish locale is selected' do
          expect(page_es.slug).not_to eq page.slug # Ensure the slugs are different
          get :show, params: { exhibit_id: exhibit.id, id: page.slug, locale: 'es' }
          expect(response).to redirect_to(exhibit_feature_page_path(exhibit, page_es))
        end
      end
    end

    describe 'GET new' do
      it 'assigns a new page as @page' do
        get :new, params: { exhibit_id: exhibit }
        expect(assigns(:page)).to be_a_new(Spotlight::FeaturePage)
        expect(assigns(:page).exhibit).to eq exhibit
      end
    end

    describe 'GET edit' do
      let(:page) { FactoryBot.create(:feature_subpage, exhibit: exhibit) }
      it 'assigns the requested page as @page' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_root_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Feature pages', exhibit_feature_pages_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with(page.parent_page.title, [exhibit, page.parent_page])
        expect(controller).to receive(:add_breadcrumb).with(page.title, [:edit, exhibit, page])
        get :edit, params: { exhibit_id: page.exhibit.id, id: page.id }
        expect(assigns(:page)).to eq page
      end
    end

    describe 'POST create' do
      describe 'with valid params' do
        it 'creates a new Page' do
          expect do
            post :create, params: { feature_page: { title: 'MyString' }, exhibit_id: exhibit }
          end.to change(Spotlight::FeaturePage, :count).by(1)
        end

        it 'assigns a newly created page as @page' do
          post :create, params: { feature_page: { title: 'MyString' }, exhibit_id: exhibit }
          expect(assigns(:page)).to be_a(Spotlight::FeaturePage)
          expect(assigns(:page)).to be_persisted
        end
        it 'redirects to the feature page index' do
          post :create, params: { feature_page: { title: 'MyString' }, exhibit_id: exhibit }
          expect(response).to redirect_to(exhibit_feature_pages_path(Spotlight::FeaturePage.last.exhibit))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved page as @page' do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Spotlight::FeaturePage).to receive(:save).and_return(false)
          post :create, params: { feature_page: { 'title' => 'invalid value' }, exhibit_id: exhibit }
          expect(assigns(:page)).to be_a_new(Spotlight::FeaturePage)
        end

        it "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Spotlight::FeaturePage).to receive(:save).and_return(false)
          post :create, params: { feature_page: { 'title' => 'invalid value' }, exhibit_id: exhibit }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'PUT update' do
      let(:page) { FactoryBot.create(:feature_page, exhibit: exhibit) }
      describe 'with valid params' do
        it 'updates the requested page' do
          expect_any_instance_of(Spotlight::FeaturePage).to receive(:update)
          put :update, params: { id: page, exhibit_id: page.exhibit.id, feature_page: valid_attributes }
        end

        it 'assigns the requested page as @page' do
          put :update, params: { id: page, exhibit_id: page.exhibit.id, feature_page: valid_attributes }
          expect(assigns(:page)).to eq(page)
        end

        it 'redirects to the feature page' do
          put :update, params: { id: page, exhibit_id: page.exhibit.id, feature_page: valid_attributes }
          page.reload
          expect(response).to redirect_to(exhibit_feature_page_path(page.exhibit, page))
          expect(flash[:notice]).to have_link 'Undo changes'
        end
      end

      describe 'with invalid params' do
        it 'assigns the page as @page' do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Spotlight::FeaturePage).to receive(:save).and_return(false)
          put :update, params: { id: page, exhibit_id: page.exhibit.id, feature_page: { 'title' => 'invalid value' } }
          expect(assigns(:page)).to eq(page)
        end

        it "re-renders the 'edit' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Spotlight::FeaturePage).to receive(:save).and_return(false)
          put :update, params: { id: page, exhibit_id: page.exhibit.id, feature_page: { 'title' => 'invalid value' } }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'POST update_all' do
      let!(:page1) { FactoryBot.create(:feature_page, exhibit: exhibit) }
      let!(:page2) { FactoryBot.create(:feature_page, exhibit: page1.exhibit) }
      let!(:page3) { FactoryBot.create(:feature_page, exhibit: page1.exhibit, parent_page_id: page1.id) }
      before { request.env['HTTP_REFERER'] = 'http://example.com' }
      it 'updates the parent/child relationship' do
        post :update_all, params: { exhibit_id: page1.exhibit, exhibit: { feature_pages_attributes: [{ id: page2.id, parent_page_id: page1.id }] } }
        expect(response).to redirect_to 'http://example.com'
        expect(flash[:notice]).to eq 'Feature pages were successfully updated.'
        expect(page1.parent_page).to be_nil
        expect(page1.child_pages).to include page2
        expect(page3.parent_page).to eq page1 # should remain untouched since in wasn't present
      end
    end

    describe 'DELETE destroy' do
      let!(:page) { FactoryBot.create(:feature_page, exhibit: exhibit) }
      it 'destroys the requested page' do
        expect do
          delete :destroy, params: { id: page, exhibit_id: page.exhibit.id }
        end.to change(Spotlight::FeaturePage, :count).by(-1)
      end

      it 'redirects to the pages list' do
        delete :destroy, params: { id: page, exhibit_id: page.exhibit.id }
        expect(response).to redirect_to(exhibit_feature_pages_path(page.exhibit))
      end
    end

    describe 'GET clone' do
      let!(:page) { FactoryBot.create(:feature_page, exhibit: exhibit) }

      it 'calls the CloneTranslatedPageFromLocale service' do
        expect(
          Spotlight::CloneTranslatedPageFromLocale
        ).to receive(:call).with(locale: 'es', page: page).and_call_original

        get :clone, params: { exhibit_id: exhibit.id, id: page.id, language: 'es' }
      end
    end
  end
end
