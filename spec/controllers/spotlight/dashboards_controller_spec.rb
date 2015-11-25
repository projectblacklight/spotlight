require 'spec_helper'

describe Spotlight::DashboardsController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:repository) { double }

  before do
    allow(controller).to receive(:repository).and_return(repository)
  end

  describe 'when logged in' do
    let(:curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
    before { sign_in curator }
    describe 'GET show' do
      it 'loads the exhibit' do
        exhibit.blacklight_configuration.index = { timestamp_field: 'timestamp_field' }
        exhibit.save!
        expect(controller).to receive(:search_results).with({ sort: 'timestamp_field desc' }, kind_of(Array)).and_return([double(:response), [{ id: 1 }]])
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Dashboard', exhibit_dashboard_path(exhibit))
        get :show, exhibit_id: exhibit.id
        expect(response).to render_template 'spotlight/dashboards/show'
        expect(assigns[:exhibit]).to eq exhibit
        expect(assigns[:pages].length).to eq exhibit.pages.length
        expect(assigns[:solr_documents]).to have(1).item
      end
    end

    describe 'GET analytics' do
      it 'loads the exhibit' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Analytics', analytics_exhibit_dashboard_path(exhibit))
        get :analytics, exhibit_id: exhibit.id
        expect(response).to render_template 'spotlight/dashboards/analytics'
        expect(assigns[:exhibit]).to eq exhibit
      end
    end
  end

  describe 'when user does not have access' do
    before { sign_in FactoryGirl.create(:exhibit_visitor) }
    it 'does not allow show' do
      get :show, exhibit_id: exhibit.id
      expect(response).to redirect_to main_app.root_path
    end

    it 'does not allow analytics' do
      get :analytics, exhibit_id: exhibit.id
      expect(response).to redirect_to main_app.root_path
    end
  end

  describe 'when not logged in' do
    describe 'GET show' do
      it 'redirects to the sign in form' do
        get :show, exhibit_id: exhibit.id
        expect(response).to redirect_to(main_app.new_user_session_path)
        expect(flash[:alert]).to be_present
        expect(flash[:alert]).to match(/You need to sign in/)
      end
    end
  end
end
