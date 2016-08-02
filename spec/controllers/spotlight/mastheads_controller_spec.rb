describe Spotlight::MastheadsController, type: :controller do
  routes { Spotlight::Engine.routes }

  describe 'when the user is not authorized' do
    before do
      sign_in FactoryGirl.create(:exhibit_visitor)
    end

    describe 'POST create' do
      it 'denies access' do
        post :create
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end
  end

  context 'when signed in as a site admin' do
    let(:user) { FactoryGirl.create(:site_admin) }
    before { sign_in user }

    context 'POST create for a site' do
      it 'is successful' do
        expect do
          post :create, params: {
            site: {
              masthead_attributes: {
                file: fixture_file_upload('spec/fixtures/800x600.png', 'image/png')
              }
            }
          }
        end.to change { Spotlight::Masthead.count }.by(1)

        expect(response).to be_successful
        expect(response.body).to match %r{\{"tilesource":"http://test\.host/images/\d+/info\.json","id":\d+\}}
      end
    end

    context 'POST create for an exhibit' do
      it 'is successful' do
        expect do
          post :create, params: {
            exhibit: {
              masthead_attributes: {
                file: fixture_file_upload('spec/fixtures/800x600.png', 'image/png')
              }
            }
          }
        end.to change { Spotlight::Masthead.count }.by(1)

        expect(response).to be_successful
        expect(response.body).to match %r{\{"tilesource":"http://test\.host/images/\d+/info\.json","id":\d+\}}
      end
    end
  end
end
