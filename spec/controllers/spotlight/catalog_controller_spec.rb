require 'spec_helper'

describe Spotlight::CatalogController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  it { is_expected.to be_a_kind_of ::CatalogController }
  it { is_expected.to be_a_kind_of Spotlight::Concerns::ApplicationController }
  its(:view_context) { should be_a_kind_of Spotlight::ApplicationHelper }

  describe 'when the user is not authenticated' do
    describe 'GET admin' do
      it 'redirects to the login page' do
        get :admin, exhibit_id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'GET edit' do
      it 'is not allowed' do
        get :edit, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'GET show' do
      let(:document) { SolrDocument.find('dq287tq6352') }
      let(:search) { FactoryGirl.create(:search, exhibit: exhibit) }
      it 'shows the item' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_path(exhibit, q: ''))
        expect(controller).to receive(:add_breadcrumb).with("L'AMERIQUE", exhibit_catalog_path(exhibit, document))
        get :show, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to be_successful
      end

      it 'shows the item with breadcrumbs to the browse page' do
        allow(controller).to receive_messages(current_browse_category: search)

        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_path(exhibit, q: ''))
        expect(controller).to receive(:add_breadcrumb).with('Browse', exhibit_browse_index_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with(search.title, exhibit_browse_path(exhibit, search))
        expect(controller).to receive(:add_breadcrumb).with("L'AMERIQUE", exhibit_catalog_path(exhibit, document))
        get :show, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to be_successful
      end

      it 'shows the item with breadcrumbs to the feature page' do
        feature_page = FactoryGirl.create(:feature_page, exhibit: exhibit)
        allow(controller).to receive_messages(current_page_context: feature_page)

        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_path(exhibit, q: ''))
        expect(controller).to receive(:add_breadcrumb).with(feature_page.title, [exhibit, feature_page])
        expect(controller).to receive(:add_breadcrumb).with("L'AMERIQUE", exhibit_catalog_path(exhibit, document))
        get :show, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to be_successful
      end

      it 'shows the item with breadcrumbs from the home page' do
        home_page = FactoryGirl.create(:home_page)
        allow(controller).to receive_messages(current_page_context: home_page)

        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_path(exhibit, q: ''))
        expect(controller).to receive(:add_breadcrumb).with("L'AMERIQUE", exhibit_catalog_path(exhibit, document))
        get :show, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to be_successful
      end

      it 'adds the curation widget' do
        get :show, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(controller.blacklight_config.show.partials.first).to eq 'curation_mode_toggle'
      end

      it 'does not have a solr_json serialization' do
        get :show, exhibit_id: exhibit, id: 'dq287tq6352', format: :solr_json
        expect(response).not_to be_successful
      end
    end

    describe 'GET index' do
      it 'shows the index when there are parameters' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_path(exhibit, q: ''))
        expect(controller).to receive(:add_breadcrumb).with('Search Results', exhibit_catalog_index_path(exhibit, q: 'map'))
        get :index, exhibit_id: exhibit, q: 'map'
        expect(response).to be_successful
      end
      it 'redirects to the exhibit home page when there are no parameters' do
        get :index, exhibit_id: exhibit
        expect(response).to redirect_to(exhibit_root_path(exhibit))
      end
    end

    describe 'GET autocomplete' do
      it 'has partial matches for title' do
        # Testing with ps921pn8250 because it has html escapable characters in the title (c&#39;estadire)
        get :autocomplete, exhibit_id: exhibit, q: 'PLANIS', format: 'json'
        expect(assigns[:document_list].first.id).to eq 'ps921pn8250'
        expect(response).to be_successful
        json = JSON.parse(response.body)
        doc = json['docs'].first
        expect(doc).to include 'id', 'title', 'description', 'thumbnail', 'url'
        expect(doc['id']).to eq 'ps921pn8250'
        expect(doc['description']).to eq 'ps921pn8250'
        expect(doc['title']).to eq "PLANISPHERE URANO-GEOGRAPHIQUE c'estadire LES SPHERES CELESTE et TERRESTRE mises en plan."
        expect(doc['thumbnail']).to eq assigns[:document_list].first.first(:thumbnail_url_ssm)
        expect(doc['url']).to eq exhibit_catalog_path(exhibit, id: 'ps921pn8250')
      end
      it 'has partial matches for id' do
        get :autocomplete, exhibit_id: exhibit, q: 'dx157', format: 'json'
        expect(assigns[:document_list].first.id).to eq 'dx157dh4345'
        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json['docs'].first['id']).to eq 'dx157dh4345'
        expect(json['docs'].first['title']).to eq 'KAART der REYZE van drie Schepen naar het ZUYDLAND in de Jaaren 1721 en 1722'
      end
    end
  end

  describe 'when the user is not authorized' do
    before do
      sign_in FactoryGirl.create(:exhibit_visitor)
    end

    describe 'GET index' do
      it 'applies gated discovery access controls' do
        expect(controller.search_params_logic).to include :apply_permissive_visibility_filter
      end
    end

    describe 'GET admin' do
      it 'denies access' do
        get :admin, exhibit_id: exhibit
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end

    describe 'GET edit' do
      it 'is not allowed' do
        get :edit, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
      end
    end

    describe 'GET show with private item' do
      it 'is not allowed' do
        allow_any_instance_of(::SolrDocument).to receive(:private?).and_return(true)
        get :show, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
      end
    end

    describe 'PUT make_public' do
      it 'is not allowed' do
        put :make_public, exhibit_id: exhibit, catalog_id: 'dq287tq6352'
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
      end
    end

    describe 'DELETE make_private' do
      it 'is not allowed' do
        delete :make_private, exhibit_id: exhibit, catalog_id: 'dq287tq6352'
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
      end
    end
  end

  describe 'when the user is a curator' do
    before { sign_in FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }

    it 'shows all the items' do
      expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_path(exhibit, q: ''))
      expect(controller).to receive(:add_breadcrumb).with('Curation', exhibit_dashboard_path(exhibit))
      expect(controller).to receive(:add_breadcrumb).with('Items', admin_exhibit_catalog_index_path(exhibit))
      get :admin, exhibit_id: exhibit
      expect(response).to be_successful
      expect(assigns[:document_list]).to be_a Array
      expect(assigns[:exhibit]).to eq exhibit
      expect(response).to render_template 'spotlight/catalog/admin'
      expect(controller.blacklight_config.view.admin_table.document_actions).to be_empty
    end

    it 'uses the admin table view and hide the document actions' do
      get :admin, exhibit_id: exhibit

      expect(controller.blacklight_config.view.to_h.keys).to match_array [:admin_table]
      expect(controller.blacklight_config.view.admin_table.document_actions).to be_empty
    end

    describe 'GET edit' do
      it 'is successful' do
        get :edit, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to be_successful
        expect(assigns[:exhibit]).to eq exhibit
        expect(assigns[:document]).to be_kind_of SolrDocument
      end
    end
    describe 'PATCH update' do
      it 'is successful' do
        expect do
          patch :update, exhibit_id: exhibit, id: 'dq287tq6352', solr_document: { exhibit_tag_list: 'one, two' }
        end.to change { exhibit.owned_taggings.count }.by(2)
      end
    end

    describe 'PUT make_public' do
      before do
        request.env['HTTP_REFERER'] = 'where_i_came_from'
        allow_any_instance_of(::SolrDocument).to receive(:reindex)
      end

      it 'is successful' do
        expect_any_instance_of(::SolrDocument).to receive(:reindex)
        expect_any_instance_of(::SolrDocument).to receive(:make_public!).with(exhibit)
        put :make_public, exhibit_id: exhibit, catalog_id: 'dq287tq6352'
        expect(response).to redirect_to 'where_i_came_from'
      end
    end

    describe 'DELETE make_private' do
      before do
        request.env['HTTP_REFERER'] = 'where_i_came_from'
        allow_any_instance_of(::SolrDocument).to receive(:reindex)
      end

      it 'is successful' do
        expect_any_instance_of(::SolrDocument).to receive(:reindex)
        expect_any_instance_of(::SolrDocument).to receive(:make_private!).with(exhibit)
        delete :make_private, exhibit_id: exhibit, catalog_id: 'dq287tq6352'
        expect(response).to redirect_to 'where_i_came_from'
      end
    end
  end

  describe 'when the user is a site admin' do
    before { sign_in FactoryGirl.create(:site_admin, exhibit: exhibit) }

    describe 'GET show' do
      it 'has a solr_json serialization' do
        get :show, exhibit_id: exhibit, id: 'dq287tq6352', format: :solr_json
        expect(response).to be_successful
        data = JSON.parse(response.body).with_indifferent_access
        expect(data).to include id: 'dq287tq6352'
        expect(data).to include exhibit.solr_data
        expect(data).to include ::SolrDocument.solr_field_for_tagger(exhibit)
      end
    end
  end

  describe '.exhibit_search_facet_url' do
    before do
      allow(subject).to receive(:current_exhibit).and_return(exhibit)
    end

    it 'routes to the facet page' do
      url = subject.exhibit_search_facet_url(id: 'x').sub('http://test.host/spotlight/', '/')
      route = Spotlight::Engine.routes.recognize_path(url)
      expect(route).to include controller: 'spotlight/catalog',
                               action: 'facet',
                               id: 'x'
    end

    it 'preserves the current exhibit context' do
      url = subject.exhibit_search_facet_url(id: 'x').sub('http://test.host/spotlight/', '/')
      route = Spotlight::Engine.routes.recognize_path(url)
      expect(route).to include exhibit_id: exhibit.slug
    end

    context 'with search parameters' do
      before do
        allow(subject).to receive(:search_results).and_return([])
      end

      it 'preserves query parameters' do
        get :index, q: 'xyz', exhibit_id: exhibit
        url = subject.exhibit_search_facet_url(id: 'x')
        expect(url).to include '?q=xyz'
      end
    end
  end

  describe 'next and previous documents' do
    before do
      exhibit.searches.first.update(published: true)
      allow(controller).to receive(:current_search_session).and_return(search)
      allow(controller).to receive(:search_session).and_return(search_session)
    end

    let(:search_session) { { 'counter' => 2 } }

    let(:response) { double(total: 5, documents: [first_doc, nil, last_doc]) }
    let(:first_doc) { double }
    let(:last_doc) { double }

    context 'when arriving from a browse page' do
      let(:search) do
        Search.new(query_params: { action: 'show', controller: 'spotlight/browse', id: exhibit.searches.first.id }.with_indifferent_access)
      end

      context 'when published' do
        before do
          exhibit.searches.first.update(published: true)
          allow(controller).to receive(:get_previous_and_next_documents_for_search).with(1, exhibit.searches.first.query_params).and_return(response)
        end

        it 'uses the saved search context' do
          get :show, exhibit_id: exhibit, id: 'dq287tq6352'

          expect(assigns(:previous_document)).to eq first_doc
          expect(assigns(:next_document)).to eq last_doc
        end
      end

      context 'when arriving from a private browse page' do
        before do
          exhibit.searches.first.update(published: false)
        end

        it 'ignores the search context' do
          get :show, exhibit_id: exhibit, id: 'dq287tq6352'

          expect(assigns(:previous_document)).to be_nil
          expect(assigns(:next_document)).to be_nil
        end
      end
    end

    context 'when arriving from a feature page' do
      let(:page) { FactoryGirl.create(:feature_page, exhibit: exhibit) }
      let(:search) do
        Search.new(query_params: { action: 'show', controller: 'spotlight/feature_pages', id: page.id }.with_indifferent_access)
      end

      context 'when published' do
        before do
          page.update(published: true)
        end

        it 'uses the page context' do
          pending 'Waiting to figure out how to construct previous/next documents'
          get :show, exhibit_id: exhibit, id: 'dq287tq6352'

          expect(assigns(:previous_document)).to be_a_kind_of SolrDocument
          expect(assigns(:next_document)).to be_a_kind_of SolrDocument
        end
      end

      context 'when unpublished' do
        before do
          page.update(published: false)
        end

        it 'ignores the search context' do
          get :show, exhibit_id: exhibit, id: 'dq287tq6352'

          expect(assigns(:previous_document)).to be_nil
          expect(assigns(:next_document)).to be_nil
        end
      end
    end
  end
end
