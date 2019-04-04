# frozen_string_literal: true

describe Spotlight::CatalogController, type: :controller do
  include ActiveJob::TestHelper
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryBot.create(:exhibit) }

  it { is_expected.to be_a_kind_of ::CatalogController }
  it { is_expected.to be_a_kind_of Spotlight::Concerns::ApplicationController }
  its(:view_context) { should be_a_kind_of Spotlight::ApplicationHelper }

  describe 'when the user is not authenticated' do
    describe 'GET admin' do
      it 'redirects to the login page' do
        get :admin, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'GET edit' do
      it 'is not allowed' do
        get :edit, params: { exhibit_id: exhibit, id: 'dq287tq6352' }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'GET show' do
      let(:document) { SolrDocument.new(id: 'dq287tq6352') }
      let(:search) { FactoryBot.create(:search, exhibit: exhibit) }
      it 'shows the item' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_path(exhibit, q: ''))
        expect(controller).to receive(:add_breadcrumb).with("L'AMERIQUE", exhibit_solr_document_path(exhibit, document))
        get :show, params: { exhibit_id: exhibit, id: 'dq287tq6352' }
        expect(response).to be_successful
      end

      it 'shows the item with breadcrumbs to the browse page' do
        allow(controller).to receive_messages(current_browse_category: search)

        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_path(exhibit, q: ''))
        expect(controller).to receive(:add_breadcrumb).with('Browse', exhibit_browse_index_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with(search.title, exhibit_browse_path(exhibit, search))
        expect(controller).to receive(:add_breadcrumb).with("L'AMERIQUE", exhibit_solr_document_path(exhibit, document))
        get :show, params: { exhibit_id: exhibit, id: 'dq287tq6352' }
        expect(response).to be_successful
      end

      it 'shows the item with breadcrumbs to the feature page' do
        feature_page = FactoryBot.create(:feature_page, exhibit: exhibit)
        allow(controller).to receive_messages(current_page_context: feature_page)

        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_path(exhibit, q: ''))
        expect(controller).to receive(:add_breadcrumb).with(feature_page.title, [exhibit, feature_page])
        expect(controller).to receive(:add_breadcrumb).with("L'AMERIQUE", exhibit_solr_document_path(exhibit, document))
        get :show, params: { exhibit_id: exhibit, id: 'dq287tq6352' }
        expect(response).to be_successful
      end

      it 'shows the item with breadcrumbs from the home page' do
        home_page = FactoryBot.create(:home_page)
        allow(controller).to receive_messages(current_page_context: home_page)

        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_path(exhibit, q: ''))
        expect(controller).to receive(:add_breadcrumb).with("L'AMERIQUE", exhibit_solr_document_path(exhibit, document))
        get :show, params: { exhibit_id: exhibit, id: 'dq287tq6352' }
        expect(response).to be_successful
      end

      it 'adds the curation widget' do
        get :show, params: { exhibit_id: exhibit, id: 'dq287tq6352' }
        expect(controller.blacklight_config.show.partials.first).to eq 'curation_mode_toggle'
      end

      it 'does not have a solr_json serialization' do
        get :show, params: { exhibit_id: exhibit, id: 'dq287tq6352', format: :solr_json }
        expect(response).not_to be_successful
      end
    end

    describe 'GET index' do
      it 'shows the index when there are parameters' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_path(exhibit, q: ''))
        expect(controller).to receive(:add_breadcrumb).with('Search Results', search_exhibit_catalog_path(exhibit, q: 'map'))
        get :index, params: { exhibit_id: exhibit, q: 'map' }
        expect(response).to be_successful
      end
      it 'redirects to the exhibit home page when there are no parameters' do
        get :index, params: { exhibit_id: exhibit }
        expect(response).to redirect_to(exhibit_root_path(exhibit))
      end
    end

    describe 'GET autocomplete' do
      it 'has partial matches for title' do
        # Testing with ps921pn8250 because it has html escapable characters in the title (c&#39;estadire)
        get :autocomplete, params: { exhibit_id: exhibit, q: 'PLANIS', format: 'json' }
        expect(assigns[:document_list].first.id).to eq 'ps921pn8250'
        expect(response).to be_successful
        json = JSON.parse(response.body)
        doc = json['docs'].first
        expect(doc).to include 'id', 'title', 'description', 'thumbnail', 'url'
        expect(doc['id']).to eq 'ps921pn8250'
        expect(doc['description']).to eq 'ps921pn8250'
        expect(doc['title']).to eq "PLANISPHERE URANO-GEOGRAPHIQUE c'estadire LES SPHERES CELESTE et TERRESTRE mises en plan."
        expect(doc['thumbnail']).to eq assigns[:document_list].first.first(:thumbnail_url_ssm)
        expect(doc['url']).to eq exhibit_solr_document_path(exhibit, id: 'ps921pn8250')
      end
      it 'has partial matches for id' do
        get :autocomplete, params: { exhibit_id: exhibit, q: 'dx157', format: 'json' }
        expect(assigns[:document_list].first.id).to eq 'dx157dh4345'
        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json['docs'].first['id']).to eq 'dx157dh4345'
        expect(json['docs'].first['title']).to eq 'KAART der REYZE van drie Schepen naar het ZUYDLAND in de Jaaren 1721 en 1722'
      end
    end

    describe 'GET manifest' do
      context 'document is an uploaded resource' do
        it 'returns the json manifest produced by Spotlight::IiifManifestPresenter, based on the retrieved document and the controller' do
          uploaded_resource = FactoryBot.create(:uploaded_resource)
          compound_id = uploaded_resource.compound_id
          slug = uploaded_resource.exhibit.slug

          perform_enqueued_jobs do
            uploaded_resource.save_and_index
          end

          get :manifest, params: { exhibit_id: uploaded_resource.exhibit, id: compound_id }

          expect(response).to be_successful

          json = JSON.parse(response.body)
          expect(json['@context']).to eq 'http://iiif.io/api/presentation/2/context.json'
          expect(json['@id']).to eq "http://test.host/spotlight/#{slug}/catalog/#{compound_id}/manifest"
          expect(json['@type']).to eq 'sc:Manifest'

          canvas = json['sequences'].first['canvases'].first
          expect(canvas['@id']).to eq "http://test.host/spotlight/#{slug}/catalog/#{compound_id}/manifest/canvas/#{compound_id}"
          expect(canvas['@type']).to eq 'sc:Canvas'

          image = canvas['images'].first
          expect(image['resource']['@id']).to eq compound_id
          expect(image['resource']['format']).to eq 'image/jpeg'

          # clean up solr document created by save_and_index above
          Blacklight.default_index.connection.delete_by_id uploaded_resource.compound_id
          Blacklight.default_index.connection.commit
        end
      end

      context 'document is not an uploaded resource' do
        it 'returns a 404 when called on something other than an uploaded resource' do
          get :manifest, params: { exhibit_id: exhibit, id: 'dx157dh4345' }
          expect(response).not_to be_successful
          expect(response.status).to eq(404)
        end
      end
    end
  end

  describe 'when the user is not authorized' do
    before do
      sign_in FactoryBot.create(:exhibit_visitor)
    end

    describe 'GET admin' do
      it 'denies access' do
        get :admin, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end

    describe 'GET edit' do
      it 'is not allowed' do
        get :edit, params: { exhibit_id: exhibit, id: 'dq287tq6352' }
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
      end
    end

    describe 'GET show with private item' do
      it 'is not allowed' do
        allow_any_instance_of(::SolrDocument).to receive(:private?).and_return(true)
        get :show, params: { exhibit_id: exhibit, id: 'dq287tq6352' }
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
      end
    end

    describe 'PUT make_public' do
      it 'is not allowed' do
        put :make_public, params: { exhibit_id: exhibit, id: 'dq287tq6352' }

        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
      end
    end

    describe 'DELETE make_private' do
      it 'is not allowed' do
        delete :make_private, params: { exhibit_id: exhibit, id: 'dq287tq6352' }
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
      end
    end
  end

  describe 'when the user is a curator' do
    before { sign_in FactoryBot.create(:exhibit_curator, exhibit: exhibit) }

    it 'shows all the items' do
      expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_path(exhibit, q: ''))
      expect(controller).to receive(:add_breadcrumb).with('Curation', exhibit_dashboard_path(exhibit))
      expect(controller).to receive(:add_breadcrumb).with('Items', admin_exhibit_catalog_path(exhibit))
      get :admin, params: { exhibit_id: exhibit }
      expect(response).to be_successful
      expect(assigns[:document_list]).to be_a Array
      expect(assigns[:exhibit]).to eq exhibit
      expect(response).to render_template 'spotlight/catalog/admin'
      expect(controller.blacklight_config.view.admin_table.document_actions).to be_empty
    end

    it 'uses the admin table view and hide the document actions' do
      get :admin, params: { exhibit_id: exhibit }

      expect(controller.blacklight_config.view.to_h.keys).to match_array [:admin_table]
      expect(controller.blacklight_config.view.admin_table.document_actions).to be_empty
    end

    describe 'GET edit' do
      it 'is successful' do
        get :edit, params: { exhibit_id: exhibit, id: 'dq287tq6352' }
        expect(response).to be_successful
        expect(assigns[:exhibit]).to eq exhibit
        expect(assigns[:document]).to be_kind_of SolrDocument
      end
    end

    describe 'PATCH update' do
      it 'is successful' do
        expect do
          patch :update, params: { exhibit_id: exhibit, id: 'dq287tq6352', solr_document: { exhibit_tag_list: 'one, two' } }
        end.to change { exhibit.owned_taggings.count }.by(2)
      end
      it 'can update non-readonly fields' do
        field = FactoryBot.create(:custom_field, exhibit: exhibit)
        patch :update, params: { exhibit_id: exhibit, id: 'dq287tq6352', solr_document: { sidecar: { data: { field.field => 'no' } } } }
        expect(assigns[:document].sidecar(exhibit).data).to eq(field.field => 'no')
      end
      it "can't update readonly fields" do
        field = FactoryBot.create(:custom_field, exhibit: exhibit, readonly_field: true)
        patch :update, params: { exhibit_id: exhibit, id: 'dq287tq6352', solr_document: { sidecar: { data: { field.field => 'no' } } } }
        expect(assigns[:document].sidecar(exhibit).data).to eq({})
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
        put :make_public, params: { exhibit_id: exhibit, id: 'dq287tq6352' }
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
        delete :make_private, params: { exhibit_id: exhibit, id: 'dq287tq6352' }
        expect(response).to redirect_to 'where_i_came_from'
      end
    end
  end

  describe 'when the user is a site admin' do
    before { sign_in FactoryBot.create(:site_admin, exhibit: exhibit) }

    describe 'GET show' do
      it 'has a solr_json serialization' do
        get :show, params: { exhibit_id: exhibit, id: 'dq287tq6352', format: :solr_json }
        expect(response).to be_successful
        data = JSON.parse(response.body).with_indifferent_access
        expect(data).to include id: 'dq287tq6352'
        expect(data).to include exhibit.solr_data
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
        get :index, params: { q: 'xyz', exhibit_id: exhibit }
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
          allow(controller).to receive(:get_previous_and_next_documents_for_search).with(
            1, exhibit.searches.first.query_params
          ).and_return([response, [first_doc, last_doc]])
        end

        it 'uses the saved search context' do
          get :show, params: { exhibit_id: exhibit, id: 'dq287tq6352' }

          expect(assigns(:previous_document)).to eq first_doc
          expect(assigns(:next_document)).to eq last_doc
        end
      end

      context 'when arriving from a private browse page' do
        before do
          exhibit.searches.first.update(published: false)
        end

        it 'ignores the search context' do
          get :show, params: { exhibit_id: exhibit, id: 'dq287tq6352' }

          expect(assigns(:previous_document)).to be_nil
          expect(assigns(:next_document)).to be_nil
        end
      end
    end

    context 'when arriving from a feature page' do
      let(:page) { FactoryBot.create(:feature_page, exhibit: exhibit) }
      let(:search) do
        Search.new(query_params: { action: 'show', controller: 'spotlight/feature_pages', id: page.id }.with_indifferent_access)
      end

      context 'when published' do
        before do
          page.update(published: true)
        end

        it 'uses the page context' do
          pending 'Waiting to figure out how to construct previous/next documents'
          get :show, params: { exhibit_id: exhibit, id: 'dq287tq6352' }

          expect(assigns(:previous_document)).to be_a_kind_of SolrDocument
          expect(assigns(:next_document)).to be_a_kind_of SolrDocument
        end
      end

      context 'when unpublished' do
        before do
          page.update(published: false)
        end

        it 'ignores the search context' do
          get :show, params: { exhibit_id: exhibit, id: 'dq287tq6352' }

          expect(assigns(:previous_document)).to be_nil
          expect(assigns(:next_document)).to be_nil
        end
      end
    end
  end

  describe '#field_enabled?' do
    let(:field) { FactoryBot.create(:custom_field) }
    before do
      controller.extend(Blacklight::Catalog)
      allow(controller).to receive(:document_index_view_type).and_return(nil)
      allow(field).to receive(:enabled).and_return(true)
    end

    context 'for sort fields' do
      let(:field) { Blacklight::Configuration::SortField.new enabled: true }
      it 'uses the enabled property for sort fields' do
        expect(controller.field_enabled?(field)).to eq true
      end
    end

    context 'for search fields' do
      let(:field) { Blacklight::Configuration::SearchField.new enabled: true }
      it 'uses the enabled property for search fields' do
        expect(controller.field_enabled?(field)).to eq true
      end
    end

    it 'returns the value of field#show if the action_name is "show"' do
      allow(field).to receive(:show).and_return(:value)
      allow(controller).to receive(:action_name).and_return('show')
      expect(controller.field_enabled?(field)).to eq :value
    end
    it 'returns the value of field#show if the action_name is "edit"' do
      allow(field).to receive(:show).and_return(:value)
      allow(controller).to receive(:action_name).and_return('edit')
      expect(controller.field_enabled?(field)).to eq :value
    end
    it 'returns the value of the original if condition' do
      allow(field).to receive(:original).and_return false
      expect(controller.field_enabled?(field)).to eq false
    end
  end

  describe '#enabled_in_spotlight_view_type_configuration?' do
    let(:view) { OpenStruct.new }
    before do
      controller.extend(Blacklight::Catalog)
    end

    it 'respects the original if condition' do
      view.original = false
      expect(controller.enabled_in_spotlight_view_type_configuration?(view)).to eq false
    end

    it 'is true if there is no exhibit context' do
      allow(controller).to receive(:current_exhibit).and_return(nil)
      expect(controller.enabled_in_spotlight_view_type_configuration?(view)).to eq true
    end

    it "is true if we're in a page context" do
      allow(controller).to receive(:current_exhibit).and_return(nil)
      allow(controller).to receive(:is_a?).with(Spotlight::PagesController).and_return(true)
      expect(controller.enabled_in_spotlight_view_type_configuration?(view)).to eq true
    end
  end

  describe 'save_search rendering' do
    let(:current_exhibit) { FactoryBot.create(:exhibit) }
    before { allow(controller).to receive_messages(current_exhibit: current_exhibit) }

    describe 'render_save_this_search?' do
      it 'returns false if we are on the items admin screen' do
        allow(controller).to receive(:can?).with(:curate, current_exhibit).and_return(true)
        allow(controller).to receive(:params).and_return(controller: 'spotlight/catalog', action: 'admin')
        expect(controller.render_save_this_search?).to be_falsey
      end
      it 'returns true if we are not on the items admin screen' do
        allow(controller).to receive(:can?).with(:curate, current_exhibit).and_return(true)
        allow(controller).to receive(:params).and_return(controller: 'spotlight/catalog', action: 'index')
        expect(controller.render_save_this_search?).to be_truthy
      end
      it 'returns false if a user cannot curate the object' do
        allow(controller).to receive(:can?).with(:curate, current_exhibit).and_return(false)
        expect(controller.render_save_this_search?).to be_falsey
      end
    end
  end

  describe '#setup_next_and_previous_documents_from_browse_category' do
    let(:search_session) { { 'counter' => '1' } }
    let(:current_browse_category) { FactoryBot.create(:search, exhibit: exhibit, query_params: { q: 'Search String' }) }

    before do
      allow(controller).to receive_messages(
        current_exhibit: exhibit,
        search_session: search_session,
        current_browse_category: current_browse_category
      )
    end

    it 'sends the current browse category\'s query params to #get_previous_and_next_documents_for_search' do
      expect(controller).to receive(:get_previous_and_next_documents_for_search).with(
        0, current_browse_category.query_params
      )

      controller.send(:setup_next_and_previous_documents_from_browse_category)
    end

    it 'sets instance variables for the previous and next documents based on the return of get_previous_and_next_documents_for_search' do
      expect(controller).to receive(:get_previous_and_next_documents_for_search).with(
        0, current_browse_category.query_params
      ).and_return([instance_double('SolrResponse', total: '100'), [nil, SolrDocument.new]])

      controller.send(:setup_next_and_previous_documents_from_browse_category)
      expect(controller.instance_variable_get(:@previous_document)).to be_nil
      expect(controller.instance_variable_get(:@next_document)).to an_instance_of SolrDocument
    end
  end
end
