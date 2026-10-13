# frozen_string_literal: true

require 'rack/test'

RSpec.describe Spotlight::ExhibitsController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryBot.create(:exhibit) }

  before do
    allow(Spotlight::DefaultThumbnailJob).to receive(:perform_later)
  end

  describe 'when the user is not authorized' do
    before do
      sign_in FactoryBot.create(:exhibit_visitor)
    end

    describe 'GET edit' do
      it 'denies access' do
        get :edit, params: { id: exhibit }
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'when not logged in' do
    describe 'GET index' do
      context 'where there are no exhibits' do
        it 'is allowed' do
          get :index
          expect(response).to be_successful
        end
      end

      context 'when there is one exhibit' do
        let!(:exhibit) do
          FactoryBot.create(:exhibit)
        end

        before do
          allow(controller).to receive(:redirect_to)
        end

        it 'is allowed' do
          get :index
          expect(controller).to have_received(:redirect_to).with(exhibit, flash: {})
        end
      end

      context 'when the only exhibit is previewable' do
        before do
          FactoryBot.create(:exhibit, published: true, discovery_enabled: false)
        end

        it 'does not redirect to the exhibit' do
          get :index
          expect(response).to be_successful
          expect(assigns[:published_exhibits]).to be_empty
        end
      end

      context 'when there is one discoverable exhibit and a previewable exhibit' do
        let!(:discoverable_exhibit) { FactoryBot.create(:exhibit) }

        before do
          FactoryBot.create(:exhibit, published: true, discovery_enabled: false)
        end

        it 'redirects to the discoverable exhibit' do
          get :index
          expect(response).to redirect_to(discoverable_exhibit)
        end
      end
    end

    describe 'GET new' do
      it 'is not allowed' do
        get :new, params: { id: exhibit }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'GET edit' do
      it 'is not allowed' do
        get :edit, params: { id: exhibit }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'PATCH update' do
      it 'is not allowed' do
        patch :update, params: { id: exhibit }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'PATCH process_import' do
      it 'is not allowed' do
        patch :process_import, params: { id: exhibit }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'DELETE destroy' do
      it 'is not allowed' do
        delete :destroy, params: { id: exhibit }
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe 'when signed in as a site admin' do
    let(:user) { FactoryBot.create(:site_admin) }

    before { sign_in user }

    describe 'GET new' do
      it 'is successful' do
        get :new
        expect(response).to be_successful
      end
    end

    describe 'POST create' do
      before do
        # decouple this test from needing solr running
        allow_any_instance_of(Spotlight::Search).to receive(:set_default_featured_image)
      end

      it 'is successful' do
        expect do
          post :create, params: { exhibit: { title: 'Some Title', slug: 'custom-slug', tag_list: '2014, R. Buckminster Fuller' } }
        end.to change(Spotlight::Exhibit, :count).by(1)

        exhibit = Spotlight::Exhibit.last
        expect(response).to redirect_to(exhibit_dashboard_path(exhibit))

        expect(exhibit.title).to eq 'Some Title'
        expect(exhibit.slug).to eq 'custom-slug'
        expect(exhibit.tags.map(&:name)).to eq ['2014', 'R. Buckminster Fuller']

        expect(user.exhibits).to include exhibit
      end
    end

    describe 'GET index' do
      context 'when the only exhibit is previewable' do
        let!(:previewable_exhibit) { FactoryBot.create(:exhibit, published: true, discovery_enabled: false) }

        it 'redirects to the exhibit' do
          get :index
          expect(response).to redirect_to(previewable_exhibit)
        end
      end

      context 'when there is one discoverable exhibit and a previewable exhibit' do
        before do
          FactoryBot.create(:exhibit)
          FactoryBot.create(:exhibit, published: true, discovery_enabled: false)
        end

        it 'does not redirect' do
          get :index
          expect(response).to be_successful
        end
      end
    end
  end

  describe 'when signed in as an exhibit admin' do
    let(:user) { FactoryBot.create(:exhibit_admin, exhibit:) }

    before { sign_in user }

    describe 'GET index' do
      context "when the only exhibit is the user's previewable exhibit" do
        let(:exhibit) { FactoryBot.create(:exhibit, published: true, discovery_enabled: false) }

        it 'redirects to the exhibit' do
          get :index
          expect(response).to redirect_to(exhibit)
        end
      end

      context "when the only exhibit is the user's unpublished exhibit" do
        let(:exhibit) { FactoryBot.create(:exhibit, published: false) }

        it 'redirects to the exhibit' do
          get :index
          expect(response).to redirect_to(exhibit)
        end
      end

      context "when a different user's previewable exhibit also exists" do
        let(:exhibit) { FactoryBot.create(:exhibit, published: true, discovery_enabled: false) }

        before do
          FactoryBot.create(:exhibit, published: true, discovery_enabled: false)
        end

        it "redirects to the admin's exhibit" do
          get :index
          expect(response).to redirect_to(exhibit)
        end
      end

      context "when there is a discoverable exhibit and the user's unpublished exhibit" do
        let(:exhibit) { FactoryBot.create(:exhibit, published: false) }

        before do
          FactoryBot.create(:exhibit)
        end

        it 'does not redirect' do
          get :index
          expect(response).to be_successful
        end
      end
    end

    describe 'GET new' do
      it 'is not allowed' do
        get :new
        expect(response).not_to be_successful
      end
    end

    describe 'PATCH process_import' do
      it 'is successful' do
        allow_any_instance_of(Spotlight::Exhibit).to receive(:reindex_later).and_return(true)
        f = Tempfile.new('foo')
        begin
          f.write '{ "title": "Foo", "subtitle": "Bar"}'
          f.rewind
          file = Rack::Test::UploadedFile.new(f.path, 'application/json')
          patch :process_import, params: { id: exhibit, file: }
        ensure
          f.close
          f.unlink
        end
        expect(response).to be_redirect
        assigns[:exhibit].tap do |saved|
          expect(saved.title).to eq 'Foo'
          expect(saved.subtitle).to eq 'Bar'
        end
      end
    end

    describe 'GET edit' do
      it 'is successful' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Configuration', exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('General', edit_exhibit_path(exhibit))
        get :edit, params: { id: exhibit }
        expect(response).to be_successful
      end
    end

    describe '#update' do
      it 'is successful' do
        patch :update, params: {
          id: exhibit,
          exhibit: {
            title: 'Foo',
            subtitle: 'Bar',
            description: 'Baz',
            contact_emails_attributes: { '0' => { email: 'bess@stanford.edu' }, '1' => { email: 'naomi@stanford.edu' } }
          }
        }

        expect(flash[:notice]).to eq 'The exhibit was successfully updated.'
        expect(response).to redirect_to edit_exhibit_path(exhibit)
        assigns[:exhibit].tap do |saved|
          expect(saved.title).to eq 'Foo'
          expect(saved.subtitle).to eq 'Bar'
          expect(saved.description).to eq 'Baz'
          expect(saved.contact_emails.pluck(:email)).to eq ['bess@stanford.edu', 'naomi@stanford.edu']
        end
      end

      it 'shows errors and ignore blank emails' do
        patch :update, params: {
          id: exhibit,
          exhibit: {
            title: 'Foo',
            subtitle: 'Bar',
            description: 'Baz',
            contact_emails_attributes: { '0' => { email: 'bess@stanford.edu' }, '1' => { email: 'naomi@' }, '2' => { email: '' } }
          }
        }

        expect(response).to be_successful
        assigns[:exhibit].tap do |obj|
          expect(obj.contact_emails.last.errors[:email]).to eq ['is not valid']
          expect(obj.contact_emails.size).to eq 2
        end
      end
    end

    describe '#destroy' do
      it 'is successful' do
        delete :destroy, params: { id: exhibit }
        expect(Spotlight::Exhibit).not_to exist(exhibit.id)
        expect(flash[:notice]).to eq 'The exhibit was deleted.'
        expect(response).to redirect_to main_app.root_path
      end
    end
  end

  describe 'when signed in as an exhibit viewer' do
    let(:exhibit) { FactoryBot.create(:exhibit, published: true, discovery_enabled: false) }
    let(:user) { FactoryBot.create(:user, :with_exhibit_role, role: 'viewer', exhibit:) }

    before { sign_in user }

    describe 'GET index' do
      context "when the only exhibit is the user's previewable exhibit" do
        it 'redirects to the exhibit' do
          get :index
          expect(response).to redirect_to(exhibit)
        end
      end
    end
  end
end
