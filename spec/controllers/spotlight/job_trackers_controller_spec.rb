# frozen_string_literal: true

describe Spotlight::JobTrackersController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:job_tracker) { FactoryBot.create(:job_tracker, on: exhibit) }
  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe 'when the user is not authorized' do
    before do
      sign_in FactoryBot.create(:exhibit_visitor)
    end

    describe 'GET show' do
      it 'denies access' do
        get :show, params: { exhibit_id: exhibit, id: job_tracker }
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'when signed in' do
    let(:user) { FactoryBot.create(:exhibit_admin, exhibit:) }

    before { sign_in user }

    describe 'GET show' do
      it 'assigns breadcrumbs' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Dashboard', exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Job status', [exhibit, job_tracker])
        get :show, params: { exhibit_id: exhibit, id: job_tracker }
        expect(response).to be_successful
      end
    end
  end
end
