describe Spotlight::AboutPagesController, type: :controller, versioning: true do
  routes { Spotlight::Engine.routes }
  let(:valid_attributes) { { 'title' => 'MyString', thumbnail: { iiif_url: '' } } }
  after do
    I18n.locale = I18n.default_locale
  end

  describe 'when not logged in' do
    let(:exhibit) { FactoryBot.create(:exhibit) }
    describe 'POST update_all' do
      it 'is not allowed' do
        post :update_all, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'GET clone' do
      let(:page) { FactoryBot.create(:about_page, exhibit: exhibit) }

      it 'is not allowed' do
        get :clone, params: { exhibit_id: exhibit.id, id: page.id, language: 'es' }
        expect(flash['alert']).to eq 'You need to sign in or sign up before continuing.'
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe 'when signed in as a curator' do
    let(:exhibit) { FactoryBot.create(:exhibit) }
    let(:user) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
    before { sign_in user }

    describe 'GET show' do
      let(:page) { FactoryBot.create(:about_page, weight: 0, exhibit: exhibit) }
      let(:page2) { FactoryBot.create(:about_page, weight: 5, exhibit: exhibit) }
      describe 'on the main about page' do
        it 'is successful' do
          expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_root_path(exhibit))
          expect(controller).to receive(:add_breadcrumb).with('About', [exhibit, page])
          get :show, params: { id: page, exhibit_id: exhibit }
          expect(assigns(:page)).to eq page
          expect(assigns(:exhibit)).to eq exhibit
        end
      end
      describe 'on a different about page' do
        it 'is successful' do
          expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_root_path(exhibit))
          expect(controller).to receive(:add_breadcrumb).with('About', [exhibit, page])
          expect(controller).to receive(:add_breadcrumb).with(page2.title, [exhibit, page2])
          get :show, params: { id: page2, exhibit_id: exhibit }
          expect(assigns(:page)).to eq page2
          expect(assigns(:exhibit)).to eq exhibit
        end
      end

      describe 'under a non-default locale' do
        let!(:page_es) do
          FactoryBot.create(
            :about_page,
            title: page.title,
            weight: 0,
            exhibit: exhibit,
            locale: 'es',
            default_locale_page: page
          )
        end

        it 'renders the locale specific page' do
          get :show, params: { exhibit_id: exhibit.id, id: page.slug, locale: 'es' }

          expect(assigns[:page]).to eq page_es
        end
      end

      describe 'when "switching" locales for pages that have updated their title/slug' do
        let(:page) { FactoryBot.create(:about_page, exhibit: exhibit) }
        let!(:page_es) do
          FactoryBot.create(
            :about_page,
            exhibit: exhibit,
            title: 'Page in spanish',
            locale: 'es',
            default_locale_page: page
          )
        end

        it 'redirects from the spanish slug to the english page when the english locale is selected' do
          expect(page_es.slug).not_to eq page.slug # Ensure the slugs are different
          get :show, params: { exhibit_id: exhibit.id, id: page_es.slug, locale: 'en' }
          expect(response).to redirect_to(exhibit_about_page_path(exhibit, page))
        end

        it 'redirects from the english slug to the spanish page when the spanish locale is selected' do
          expect(page_es.slug).not_to eq page.slug # Ensure the slugs are different
          get :show, params: { exhibit_id: exhibit.id, id: page.slug, locale: 'es' }
          expect(response).to redirect_to(exhibit_about_page_path(exhibit, page_es))
        end
      end
    end

    describe 'GET edit' do
      let!(:page) { FactoryBot.create(:about_page, weight: 0, exhibit: exhibit) }
      let!(:page2) { FactoryBot.create(:about_page, weight: 5, exhibit: exhibit) }
      describe 'on the main about page' do
        it 'is successful' do
          expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_root_path(exhibit))
          expect(controller).to receive(:add_breadcrumb).with('About Pages', exhibit_about_pages_path(exhibit))
          get :edit, params: { id: page, exhibit_id: exhibit }
          expect(assigns(:page)).to eq page
          expect(assigns(:exhibit)).to eq exhibit
        end
      end
      describe 'on a different about page' do
        it 'is successful' do
          expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_root_path(exhibit))
          expect(controller).to receive(:add_breadcrumb).with('About Pages', exhibit_about_pages_path(exhibit))
          expect(controller).to receive(:add_breadcrumb).with(page2.title, [:edit, exhibit, page2])
          get :edit, params: { id: page2, exhibit_id: exhibit }
          expect(assigns(:page)).to eq page2
          expect(assigns(:exhibit)).to eq exhibit
        end
      end
    end

    describe 'GET index' do
      let!(:page) { FactoryBot.create(:about_page, exhibit: exhibit) }
      it 'is successful' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_root_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Curation', exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('About Pages', exhibit_about_pages_path(exhibit))
        get :index, params: { exhibit_id: exhibit }
        expect(assigns(:page)).to be_kind_of Spotlight::Page
        expect(assigns(:page)).to be_new_record
        expect(assigns(:pages)).to include page
        expect(assigns(:exhibit)).to eq exhibit
      end
    end
    describe 'POST create' do
      it 'redirects to the about page index' do
        post :create, params: { about_page: { title: 'MyString' }, exhibit_id: exhibit }
        expect(response).to redirect_to(exhibit_about_pages_path(exhibit))
      end
    end
    describe 'PUT update' do
      let!(:page) { FactoryBot.create(:about_page, exhibit: exhibit) }
      it 'redirects to the about page' do
        put :update, params: { id: page, exhibit_id: page.exhibit.id, about_page: valid_attributes }
        page.reload
        expect(response).to redirect_to(exhibit_about_page_path(page.exhibit, page))
        expect(flash[:notice]).to have_link 'Undo changes'
      end
    end
    describe 'POST update_all' do
      let!(:page1) { FactoryBot.create(:about_page, exhibit: exhibit) }
      let!(:page2) { FactoryBot.create(:about_page, exhibit: exhibit, published: true) }
      let!(:page3) { FactoryBot.create(:about_page, exhibit: exhibit, published: true) }
      before { request.env['HTTP_REFERER'] = 'http://example.com' }
      it 'updates whether they are on the landing page' do
        post :update_all, params: {
          exhibit_id: page1.exhibit,
          exhibit: {
            about_pages_attributes: [
              { id: page1.id, published: true, title: 'This is a new title!' },
              { id: page2.id, published: false }
            ]
          }
        }
        expect(response).to redirect_to 'http://example.com'
        expect(flash[:notice]).to eq 'About pages were successfully updated.'
        expect(page1.reload.published).to be_truthy
        expect(page1.title).to eq 'This is a new title!'
        expect(page2.reload.published).to be_falsey
        expect(page3.reload.published).to be_truthy # should remain untouched since it wasn't in present[]
      end
    end

    describe 'PATCH update_contacts' do
      let!(:contact1) { FactoryBot.create(:contact, name: 'Aphra Behn', exhibit: exhibit) }
      let!(:contact2) { FactoryBot.create(:contact, exhibit: exhibit) }
      it 'updates contacts' do
        patch :update_contacts, params: {
          exhibit_id: exhibit,
          exhibit: {
            contacts_attributes: [
              { 'show_in_sidebar' => '1', 'id' => contact1.id, weight: 1 },
              { 'show_in_sidebar' => '0', 'id' => contact2.id, weight: 2 }
            ]
          }
        }
        expect(response).to redirect_to exhibit_about_pages_path(exhibit)
        expect(flash[:notice]).to eq 'Contacts were successfully updated.'
        expect(exhibit.contacts.size).to eq 2
        expect(exhibit.contacts.published.map(&:name)).to eq ['Aphra Behn']
        expect(contact1.reload.weight).to eq 1
        expect(contact2.reload.weight).to eq 2
      end
      it 'shows index on failure' do
        expect_any_instance_of(Spotlight::Exhibit).to receive(:update).and_return(false)
        patch :update_contacts, params: {
          exhibit_id: exhibit,
          exhibit: { contacts_attributes: [
            { 'show_in_sidebar' => '1', 'name' => 'Justin Coyne', 'email' => 'jcoyne@justincoyne.com', 'title' => '', 'location' => 'US' },
            { 'show_in_sidebar' => '0', 'name' => '', 'email' => '', 'title' => '', 'location' => '' },
            { 'show_in_sidebar' => '0', 'name' => '', 'email' => '', 'title' => 'Librarian', 'location' => '' }
          ] }
        }
        expect(response).to render_template('index')
      end
    end

    describe 'GET clone' do
      let(:page) { FactoryBot.create(:about_page, exhibit: exhibit) }

      it 'calls the CloneTranslatedPageFromLocale service' do
        expect(
          Spotlight::CloneTranslatedPageFromLocale
        ).to receive(:call).with(locale: 'es', page: page).and_call_original

        get :clone, params: { exhibit_id: exhibit.id, id: page.id, language: 'es' }
      end
    end
  end
end
