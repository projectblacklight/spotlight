require 'spec_helper'

describe Spotlight::CatalogController, :type => :controller do
  routes { Spotlight::Engine.routes }
  let (:exhibit) { FactoryGirl.create(:exhibit) }
  
  it { is_expected.to be_a_kind_of ::CatalogController }
  it { is_expected.to be_a_kind_of Spotlight::Concerns::ApplicationController }
  its(:view_context) { should be_a_kind_of Spotlight::ApplicationHelper }

  describe "when the user is not authenticated" do

    describe "GET admin" do
      it "should redirect to the login page" do
        get :admin, exhibit_id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
    
    describe "GET edit" do
      it "should not be allowed" do
        get :edit, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe "GET show" do
      let (:document) { SolrDocument.find('dq287tq6352') }
      let(:search) { FactoryGirl.create(:search, exhibit: exhibit) }
      it "should show the item" do
        expect(controller).to receive(:add_breadcrumb).with("Home", exhibit_path(exhibit, q: ''))
        expect(controller).to receive(:add_breadcrumb).with("L'AMERIQUE", exhibit_catalog_path(exhibit, document))
        get :show, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to be_successful
      end

      it "should show the item with breadcrumbs to the browse page" do
        allow(controller).to receive_messages(current_browse_category: search)
        
        expect(controller).to receive(:add_breadcrumb).with("Home", exhibit_path(exhibit, q: ''))
        expect(controller).to receive(:add_breadcrumb).with("Browse", exhibit_browse_index_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with(search.title, exhibit_browse_path(exhibit, search))
        expect(controller).to receive(:add_breadcrumb).with("L'AMERIQUE", exhibit_catalog_path(exhibit, document))
        get :show, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to be_successful
      end

      it "should show the item with breadcrumbs to the feature page" do
        feature_page = FactoryGirl.create(:feature_page, exhibit: exhibit)
        allow(controller).to receive_messages(current_page_context: feature_page)

        expect(controller).to receive(:add_breadcrumb).with("Home", exhibit_path(exhibit, q: ''))
        expect(controller).to receive(:add_breadcrumb).with(feature_page.title, [exhibit, feature_page])
        expect(controller).to receive(:add_breadcrumb).with("L'AMERIQUE", exhibit_catalog_path(exhibit, document))
        get :show, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to be_successful
      end

      it "should show the item with breadcrumbs from the home page" do
        home_page = FactoryGirl.create(:home_page)
        allow(controller).to receive_messages(current_page_context: home_page)

        expect(controller).to receive(:add_breadcrumb).with("Home", exhibit_path(exhibit, q: ''))
        expect(controller).to receive(:add_breadcrumb).with("L'AMERIQUE", exhibit_catalog_path(exhibit, document))
        get :show, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to be_successful
      end

      it "should add the curation widget" do
        get :show, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(controller.blacklight_config.show.partials.first).to eq "curation_mode_toggle"
      end
    end


    describe "GET index" do
      it "should show the index when there are parameters" do
        expect(controller).to receive(:add_breadcrumb).with("Home", exhibit_path(exhibit, q: ''))
        expect(controller).to receive(:add_breadcrumb).with("Search Results", exhibit_catalog_index_path(exhibit, q:'map'))
        get :index, exhibit_id: exhibit, q: 'map'
        expect(response).to be_successful
      end
      it "should redirect to the exhibit home page when there are no parameters" do
        get :index, exhibit_id: exhibit
        expect(response).to redirect_to(exhibit_root_path(exhibit))
      end
    end

    describe "GET autocomplete" do
      it "should have partial matches for title" do
        # Testing with ps921pn8250 because it has html escapable characters in the title (c&#39;estadire)
        get :autocomplete, exhibit_id: exhibit, q: 'PLANIS', format: 'json'
        expect(assigns[:document_list].first.id).to eq 'ps921pn8250'
        expect(response).to be_successful
        json = JSON.parse(response.body)
        doc = json['docs'].first
        expect(doc).to include "id", "title", "description", "thumbnail", "url"
        expect(doc['id']).to eq 'ps921pn8250'
        expect(doc['description']).to eq 'ps921pn8250'
        expect(doc['title']).to eq "PLANISPHERE URANO-GEOGRAPHIQUE c'estadire LES SPHERES CELESTE et TERRESTRE mises en plan."
        expect(doc['thumbnail']).to eq assigns[:document_list].first.first(:thumbnail_url_ssm)
        expect(doc['url']).to eq exhibit_catalog_path(exhibit, id: 'ps921pn8250')
      end
      it "should have partial matches for id" do
        get :autocomplete, exhibit_id: exhibit, q: 'dx157', format: 'json'
        expect(assigns[:document_list].first.id).to eq 'dx157dh4345'
        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json['docs'].first['id']).to eq 'dx157dh4345'
        expect(json['docs'].first['title']).to eq "KAART der REYZE van drie Schepen naar het ZUYDLAND in de Jaaren 1721 en 1722"
      end
    end
  end

  describe "when the user is not authorized" do
    before do
      sign_in FactoryGirl.create(:exhibit_visitor)
    end

    describe "GET index" do
      it "should apply gated discovery access controls" do
        expect(controller.solr_search_params_logic).to include :apply_permissive_visibility_filter
      end
    end

    describe "GET admin" do
      it "should deny access" do
        get :admin, exhibit_id: exhibit
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end

    describe "GET edit" do
      it "should not be allowed" do
        get :edit, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to eq "You are not authorized to access this page."
      end
    end

    describe "GET show with private item" do
      it "should not be allowed" do
        allow_any_instance_of(::SolrDocument).to receive(:private?).and_return(true)
        get :show, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to eq "You are not authorized to access this page."
      end
    end

    describe "PUT make_public" do
      it "should not be allowed" do
        put :make_public, exhibit_id: exhibit, catalog_id: 'dq287tq6352'
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to eq "You are not authorized to access this page."
      end

    end

    describe "DELETE make_private" do
      it "should not be allowed" do
        delete :make_private, exhibit_id: exhibit, catalog_id: 'dq287tq6352'
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to eq "You are not authorized to access this page."
      end
    end
  end

  describe "when the user is a curator" do
    before { sign_in FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }

    it "should show all the items" do
      expect(controller).to receive(:add_breadcrumb).with("Home", exhibit_path(exhibit, q: ''))
      expect(controller).to receive(:add_breadcrumb).with("Curation", exhibit_dashboard_path(exhibit))
      expect(controller).to receive(:add_breadcrumb).with("Items", admin_exhibit_catalog_index_path(exhibit))
      get :admin, exhibit_id: exhibit
      expect(response).to be_successful
      expect(assigns[:document_list]).to be_a Array
      expect(assigns[:exhibit]).to eq exhibit
      expect(response).to render_template "spotlight/catalog/admin"
    end

    describe "GET edit" do
      it "should be successful" do
        get :edit, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to be_successful
        expect(assigns[:exhibit]).to eq exhibit
        expect(assigns[:document]).to be_kind_of SolrDocument
      end
    end
    describe "PATCH update" do
      it "should be successful" do
        patch :update, exhibit_id: exhibit, id: 'dq287tq6352', solr_document: {exhibit_tag_list: 'one, two'}
        expect(response).to be_redirect
        expect(exhibit.owned_taggings.last.tag_id).to eq 2
      end
    end


    describe "PUT make_public" do
      before do
        request.env["HTTP_REFERER"] = "where_i_came_from"
        allow_any_instance_of(::SolrDocument).to receive(:reindex)
      end

      it "should be successful" do
        expect_any_instance_of(::SolrDocument).to receive(:reindex)
        expect_any_instance_of(::SolrDocument).to receive(:make_public!).with(exhibit)
        put :make_public, exhibit_id: exhibit, catalog_id: 'dq287tq6352'
        expect(response).to redirect_to "where_i_came_from"
      end

    end

    describe "DELETE make_private" do

      before do
        request.env["HTTP_REFERER"] = "where_i_came_from"
        allow_any_instance_of(::SolrDocument).to receive(:reindex)
      end

      it "should be successful" do
        expect_any_instance_of(::SolrDocument).to receive(:reindex)
        expect_any_instance_of(::SolrDocument).to receive(:make_private!).with(exhibit)
        delete :make_private, exhibit_id: exhibit, catalog_id: 'dq287tq6352'
        expect(response).to redirect_to "where_i_came_from"
      end
    end
  end
end
