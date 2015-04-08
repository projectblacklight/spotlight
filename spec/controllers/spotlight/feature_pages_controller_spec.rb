require 'spec_helper'
describe Spotlight::FeaturePagesController, type: :controller do
  routes { Spotlight::Engine.routes }

  it { is_expected.to be_a Spotlight::Catalog::AccessControlsEnforcement }

  # This should return the minimal set of attributes required to create a valid
  # Page. As you add validations to Page, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { 'title' => 'MyString' } }
  describe 'when signed in as a curator' do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    let(:user) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
    before { sign_in user }

    describe 'GET index' do
      let!(:page) { FactoryGirl.create(:feature_page, exhibit: exhibit) }
      it 'assigns all feature pages as @pages' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_root_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Curation', exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Feature pages', exhibit_feature_pages_path(exhibit))
        get :index, exhibit_id: exhibit
        expect(assigns(:pages)).to include page
        expect(assigns(:exhibit)).to eq exhibit
      end
    end

    describe 'GET show' do
      describe 'on a top level page' do
        let(:page) { FactoryGirl.create(:feature_page, exhibit: exhibit) }
        it 'assigns the requested page as @page' do
          expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_root_path(exhibit))
          expect(controller).to receive(:add_breadcrumb).with(page.title, [exhibit, page])
          get :show, exhibit_id: page.exhibit.id, id: page
          expect(assigns(:page)).to eq(page)
        end
      end
      describe 'on a sub-page' do
        let(:page) { FactoryGirl.create(:feature_subpage, exhibit: exhibit) }
        it 'assigns the requested page as @page' do
          expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_root_path(exhibit))
          expect(controller).to receive(:add_breadcrumb).with(page.parent_page.title, [exhibit, page.parent_page])
          expect(controller).to receive(:add_breadcrumb).with(page.title, [exhibit, page])
          get :show, exhibit_id: page.exhibit, id: page
          expect(assigns(:page)).to eq(page)
        end
      end
    end

    describe 'GET new' do
      it 'assigns a new page as @page' do
        get :new, exhibit_id: exhibit
        expect(assigns(:page)).to be_a_new(Spotlight::FeaturePage)
        expect(assigns(:page).exhibit).to eq exhibit
      end
    end

    describe 'GET edit' do
      let(:page) { FactoryGirl.create(:feature_subpage, exhibit: exhibit) }
      it 'assigns the requested page as @page' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_root_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Feature pages', exhibit_feature_pages_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with(page.parent_page.title, [exhibit, page.parent_page])
        expect(controller).to receive(:add_breadcrumb).with(page.title, [:edit, exhibit, page])
        get :edit, exhibit_id: page.exhibit.id, id: page.id
        expect(assigns(:page)).to eq page
      end
    end

    describe 'POST create' do
      describe 'with valid params' do
        it 'creates a new Page' do
          expect do
            post :create, feature_page: { title: 'MyString' }, exhibit_id: exhibit
          end.to change(Spotlight::FeaturePage, :count).by(1)
        end

        it 'assigns a newly created page as @page' do
          post :create, feature_page: { title: 'MyString' }, exhibit_id: exhibit
          expect(assigns(:page)).to be_a(Spotlight::FeaturePage)
          expect(assigns(:page)).to be_persisted
        end
        it 'redirects to the feature page index' do
          post :create, feature_page: { title: 'MyString' }, exhibit_id: exhibit
          expect(response).to redirect_to(exhibit_feature_pages_path(Spotlight::FeaturePage.last.exhibit))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved page as @page' do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Spotlight::FeaturePage).to receive(:save).and_return(false)
          post :create, feature_page: { 'title' => 'invalid value' }, exhibit_id: exhibit
          expect(assigns(:page)).to be_a_new(Spotlight::FeaturePage)
        end

        it "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Spotlight::FeaturePage).to receive(:save).and_return(false)
          post :create, feature_page: { 'title' => 'invalid value' }, exhibit_id: exhibit
          expect(response).to render_template('new')
        end
      end
    end

    describe 'PUT update' do
      let(:page) { FactoryGirl.create(:feature_page, exhibit: exhibit) }
      describe 'with valid params' do
        it 'updates the requested page' do
          # Assuming there are no other pages in the database, this
          # specifies that the Page created on the previous line
          # receives the :update_attributes message with whatever params are
          # submitted in the request.
          expect_any_instance_of(Spotlight::FeaturePage).to receive(:update).with(hash_including(valid_attributes))
          put :update, id: page, exhibit_id: page.exhibit.id, feature_page: valid_attributes
        end

        it 'assigns the requested page as @page' do
          put :update, id: page, exhibit_id: page.exhibit.id, feature_page: valid_attributes
          expect(assigns(:page)).to eq(page)
        end

        it 'redirects to the feature page' do
          put :update, id: page, exhibit_id: page.exhibit.id, feature_page: valid_attributes
          page.reload
          expect(response).to redirect_to(exhibit_feature_page_path(page.exhibit, page))
          expect(flash[:notice]).to have_link 'Undo changes'
        end
      end

      describe 'with invalid params' do
        it 'assigns the page as @page' do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Spotlight::FeaturePage).to receive(:save).and_return(false)
          put :update, id: page, exhibit_id: page.exhibit.id, feature_page: { 'title' => 'invalid value' }
          expect(assigns(:page)).to eq(page)
        end

        it "re-renders the 'edit' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Spotlight::FeaturePage).to receive(:save).and_return(false)
          put :update, id: page, exhibit_id: page.exhibit.id, feature_page: { 'title' => 'invalid value' }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'POST update_all' do
      let!(:page1) { FactoryGirl.create(:feature_page, exhibit: exhibit) }
      let!(:page2) { FactoryGirl.create(:feature_page, exhibit: page1.exhibit) }
      let!(:page3) { FactoryGirl.create(:feature_page, exhibit: page1.exhibit, parent_page_id: page1.id) }
      before { request.env['HTTP_REFERER'] = 'http://example.com' }
      it 'updates the parent/child relationship' do
        post :update_all, exhibit_id: page1.exhibit, exhibit: { feature_pages_attributes: [{ id: page2.id, parent_page_id: page1.id }] }
        expect(response).to redirect_to 'http://example.com'
        expect(flash[:notice]).to eq 'Feature pages were successfully updated.'
        expect(page1.parent_page).to be_nil
        expect(page1.child_pages).to include page2
        expect(page3.parent_page).to eq page1 # should remain untouched since in wasn't present
      end
    end

    describe 'DELETE destroy' do
      let!(:page) { FactoryGirl.create(:feature_page, exhibit: exhibit) }
      it 'destroys the requested page' do
        expect do
          delete :destroy, id: page, exhibit_id: page.exhibit.id
        end.to change(Spotlight::FeaturePage, :count).by(-1)
      end

      it 'redirects to the pages list' do
        delete :destroy, id: page, exhibit_id: page.exhibit.id
        expect(response).to redirect_to(exhibit_feature_pages_path(page.exhibit))
      end
    end
  end
end
