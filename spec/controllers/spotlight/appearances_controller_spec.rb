# frozen_string_literal: true

describe Spotlight::AppearancesController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe 'when the user is not authorized' do
    before do
      sign_in FactoryBot.create(:exhibit_visitor)
    end

    describe 'GET edit' do
      it 'denies access' do
        get :edit, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'when not logged in' do
    describe 'PATCH update' do
      it 'is not allowed' do
        patch :update, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe 'when signed in' do
    let(:user) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }
    before { sign_in user }

    describe 'GET edit' do
      it 'is successful' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Configuration', exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Appearance', edit_exhibit_appearance_path(exhibit))
        get :edit, params: { exhibit_id: exhibit }
        expect(response).to be_successful
        expect(assigns[:exhibit]).to be_kind_of Spotlight::Exhibit
      end
    end

    describe 'PATCH update' do
      let(:first_nav) { exhibit.main_navigations.first }
      let(:last_nav) { exhibit.main_navigations.last }
      let(:submitted) do
        {
          exhibit_id: exhibit,
          exhibit: {
            masthead_attributes: {
              iiif_tilesource: 'http://test.host/1/foo',
              iiif_region: '0,0,2000,200'
            },
            thumbnail_attributes: {
              iiif_tilesource: 'http://test.host/2/foo',
              iiif_region: '0,0,600,600'
            },
            main_navigations_attributes: main_navigation_attributes
          }
        }
      end
      let(:main_navigation_attributes) do
        {
          0 => { id: first_nav.id, label: 'Some Label', weight: 500 },
          1 => { id: last_nav.id, display: false }
        }
      end
      it 'updates the navigation' do
        patch :update, params: submitted
        expect(flash[:notice]).to eq 'The exhibit was successfully updated.'
        expect(response).to redirect_to edit_exhibit_appearance_path(exhibit)
        assigns[:exhibit].tap do |saved|
          expect(saved.main_navigations.find(first_nav.id).label).to eq 'Some Label'
          expect(saved.main_navigations.find(first_nav.id).weight).to eq 500
          expect(saved.main_navigations.find(last_nav.id)).not_to be_displayable
          expect(saved.masthead.iiif_tilesource).to eq 'http://test.host/1/foo'
          expect(saved.thumbnail.iiif_region).to eq '0,0,600,600'
          expect(saved.masthead.iiif_url).to eq 'http://test.host/1/foo/0,0,2000,200/1800,180/0/default.jpg'
          expect(saved.thumbnail.iiif_url).to eq 'http://test.host/2/foo/0,0,600,600/400,400/0/default.jpg'
        end
      end
    end
  end
end
