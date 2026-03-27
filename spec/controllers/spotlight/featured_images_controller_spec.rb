# frozen_string_literal: true

RSpec.describe Spotlight::FeaturedImagesController, type: :controller do
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
        end.not_to change(Spotlight::FeaturedImage, :count)

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
        end.to change(Spotlight::FeaturedImage, :count).by(1)

        expect(response).to be_successful
        expect(response.body).to match %r{\{"tilesource":"/images/\d+-.+/info\.json","id":\d+\}}
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
        end.to change(Spotlight::FeaturedImage, :count).by(1)

        expect(response).to be_successful
        expect(response.body).to match %r{\{"tilesource":"/images/\d+-.+/info\.json","id":\d+\}}
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
        end.to change(Spotlight::FeaturedImage, :count).by(1)

        expect(response).to be_successful
        expect(response.body).to match %r{\{"tilesource":"/images/\d+-.+/info\.json","id":\d+\}}
      end
    end

    describe 'POST create with an upload error' do
      it 'handles CarrierWave::UploadError' do
        allow_any_instance_of(Spotlight::TemporaryImage).to receive(:save)
          .and_raise(CarrierWave::UploadError, 'File size too large')

        post :create, params: {
          featured_image: {
            image: fixture_file_upload('spec/fixtures/800x600.png', 'image/png')
          }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to eq({ 'error' => ['File size too large'] })
      end
    end
  end
end
