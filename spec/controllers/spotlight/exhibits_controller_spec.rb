require 'spec_helper'
require 'rack/test'
describe Spotlight::ExhibitsController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  before do
    allow(Spotlight::DefaultThumbnailJob).to receive(:perform_later)
  end

  describe 'when the user is not authorized' do
    before do
      sign_in FactoryGirl.create(:exhibit_visitor)
    end

    describe 'GET edit' do
      it 'denies access' do
        get :edit, id: exhibit
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'when not logged in' do
    describe 'GET index' do
      it 'is allowed' do
        get :index
        expect(response).to be_success
      end
    end

    describe 'GET new' do
      it 'is not allowed' do
        get :new, id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'GET edit' do
      it 'is not allowed' do
        get :edit, id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'PATCH update' do
      it 'is not allowed' do
        patch :update, id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'PATCH process_import' do
      it 'is not allowed' do
        patch :process_import, id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe 'DELETE destroy' do
      it 'is not allowed' do
        delete :destroy, id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe 'when signed in as a site admin' do
    let(:user) { FactoryGirl.create(:site_admin) }
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
          post :create, exhibit: { title: 'Some Title', slug: 'custom-slug', tag_list: '2014, R. Buckminster Fuller' }
        end.to change { Spotlight::Exhibit.count }.by(1)

        exhibit = Spotlight::Exhibit.last
        expect(response).to redirect_to(exhibit_dashboard_path(exhibit))

        expect(exhibit.title).to eq 'Some Title'
        expect(exhibit.slug).to eq 'custom-slug'
        expect(exhibit.tags.map(&:name)).to eq ['2014', 'R. Buckminster Fuller']

        expect(user.exhibits).to include exhibit
      end
    end
  end

  describe 'when signed in as an exhibit admin' do
    let(:user) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
    before { sign_in user }

    describe 'GET new' do
      it 'is not allowed' do
        get :new
        expect(response).to_not be_successful
      end
    end

    describe 'PATCH process_import' do
      it 'is successful' do
        expect_any_instance_of(Spotlight::Exhibit).to receive(:reindex_later).and_return(true)
        f = Tempfile.new('foo')
        begin
          f.write '{ "title": "Foo", "subtitle": "Bar"}'
          f.rewind
          file = Rack::Test::UploadedFile.new(f.path, 'application/json')
          patch :process_import, id: exhibit, file: file
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
        get :edit, id: exhibit
        expect(response).to be_successful
      end
    end

    describe '#update' do
      it 'is successful' do
        patch :update, id: exhibit, exhibit: {
          title: 'Foo',
          subtitle: 'Bar',
          description: 'Baz',
          contact_emails_attributes: { '0' => { email: 'bess@stanford.edu' }, '1' => { email: 'naomi@stanford.edu' } }
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
        patch :update, id: exhibit, exhibit: {
          title: 'Foo',
          subtitle: 'Bar',
          description: 'Baz',
          contact_emails_attributes: { '0' => { email: 'bess@stanford.edu' }, '1' => { email: 'naomi@' }, '2' => { email: '' } }
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
        delete :destroy, id: exhibit
        expect(Spotlight::Exhibit.exists?(exhibit.id)).to be_falsey
        expect(flash[:notice]).to eq 'The exhibit was deleted.'
        expect(response).to redirect_to main_app.root_path
      end
    end
  end
end
