# frozen_string_literal: true

describe Spotlight::FeaturedImagesController, type: :controller do
  routes { Spotlight::Engine.routes }

  describe 'when the user is not authorized' do
    before do
      sign_in FactoryBot.create(:exhibit_visitor)
    end

    describe 'POST create' do
      it 'denies access' do
        expect do
          post :create, params: {
            featured_image: {
              image: fixture_file_upload('spec/fixtures/800x600.png', 'image/png')
            }
          }
        end.not_to change { Spotlight::FeaturedImage.count }

        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'when signed in as a site admin' do
    let(:user) { FactoryBot.create(:site_admin) }
    before { sign_in user }

    describe 'POST create a thumbnail' do
      it 'is successful' do
        expect do
          post :create, params: {
            featured_image: {
              image: fixture_file_upload('spec/fixtures/800x600.png', 'image/png')
            }
          }
        end.to change { Spotlight::FeaturedImage.count }.by(1)

        expect(response).to be_successful
        expect(response.body).to match %r{\{"tilesource":"http://test\.host/images/\d+/info\.json","id":\d+\}}
      end
    end

    describe 'POST create a masthead' do
      it 'is successful' do
        expect do
          post :create, params: {
            featured_image: {
              image: fixture_file_upload('spec/fixtures/800x600.png', 'image/png')
            }
          }
        end.to change { Spotlight::FeaturedImage.count }.by(1)

        expect(response).to be_successful
        expect(response.body).to match %r{\{"tilesource":"http://test\.host/images/\d+/info\.json","id":\d+\}}
      end
    end

    describe 'POST create an avatar' do
      it 'is successful' do
        expect do
          post :create, params: {
            featured_image: {
              image: fixture_file_upload('spec/fixtures/800x600.png', 'image/png')
            }
          }
        end.to change { Spotlight::FeaturedImage.count }.by(1)

        expect(response).to be_successful
        expect(response.body).to match %r{\{"tilesource":"http://test\.host/images/\d+/info\.json","id":\d+\}}
      end
    end
  end
end
