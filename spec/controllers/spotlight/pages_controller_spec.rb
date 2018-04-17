describe Spotlight::PagesController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:feature_page) { FactoryBot.create(:feature_page, exhibit: exhibit, published: false) }
  let(:about_page) { FactoryBot.create(:about_page, exhibit: exhibit, published: false) }
  let(:update_all_params) do
    {
      exhibit: {
        pages_attributes: {
          0 => {
            id: feature_page.id,
            published: 1
          },
          1 => {
            id: about_page.id,
            published: 1
          }
        }
      }
    }
  end
  describe 'when signed in as a curator' do
    let(:user) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
    before do
      sign_in user
    end

    it 'the feature and about pages are updated' do
      expect(Spotlight::Page.find(feature_page.id)).not_to be_published
      expect(Spotlight::Page.find(about_page.id)).not_to be_published
      put :update_all, params: update_all_params.merge(exhibit_id: exhibit.id)
      expect(Spotlight::Page.find(feature_page.id)).to be_published
      expect(Spotlight::Page.find(about_page.id)).to be_published
    end
  end
  describe 'when user is not authenticated' do
    it 'does not allow publishing pages' do
      put :update_all, params: update_all_params.merge(exhibit_id: exhibit.id)
      expect(Spotlight::Page.find(feature_page.id)).not_to be_published
      expect(Spotlight::Page.find(about_page.id)).not_to be_published
      expect(flash['alert']).to eq 'You need to sign in or sign up before continuing.'
      expect(response).to redirect_to main_app.new_user_session_path
    end
  end
end
