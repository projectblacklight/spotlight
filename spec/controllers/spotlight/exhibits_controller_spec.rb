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

      context 'with an empty tag' do
        let!(:tagged_exhibit) { FactoryBot.create(:exhibit, tag_list: ['a']) }
        let!(:untagged_exhibit) { FactoryBot.create(:exhibit) }

        it 'assigns all the published exhibits' do
          get :index, params: { tag: '' }
          expect(assigns(:published_exhibits)).to contain_exactly(tagged_exhibit, untagged_exhibit)
        end
      end

      context 'with a search query' do
        let!(:tagged_exhibit) { FactoryBot.create(:exhibit, title: 'Some Exhibit Title', tag_list: ['a']) }
        let!(:untagged_exhibit) { FactoryBot.create(:exhibit, title: 'Some Other Title') }

        before { FactoryBot.create(:exhibit, title: 'Unrelated', tag_list: ['a']) }

        it 'assigns the published exhibits that match' do
          get :index, params: { q: 'some' }
          expect(assigns(:published_exhibits)).to contain_exactly(tagged_exhibit, untagged_exhibit)
        end

        it 'ignores an empty tag' do
          get :index, params: { q: 'some', tag: '' }
          expect(assigns(:published_exhibits)).to contain_exactly(tagged_exhibit, untagged_exhibit)
        end

        it 'searches within the selected tag' do
          get :index, params: { q: 'some', tag: 'a' }
          expect(assigns(:published_exhibits)).to eq [tagged_exhibit]
        end

        it 'pages the matching exhibits' do
          allow(Spotlight::Exhibit).to receive(:default_per_page).and_return(1)
          get :index, params: { q: 'some', page: 2 }
          expect(assigns(:published_exhibits).size).to eq 1
          expect(assigns(:published_exhibits).total_count).to eq 2
        end

        it 'keeps matching tags outside the selected tag and current page available' do
          untagged_exhibit.update!(tag_list: ['b'])
          allow(Spotlight::Exhibit).to receive(:default_per_page).and_return(1)

          get :index, params: { q: 'some', tag: 'a' }

          expect(assigns(:published_exhibits)).to eq [tagged_exhibit]
          expect(assigns(:matching_tag_names)).to contain_exactly('a', 'b')
        end

        it 'paginates after applying both the search and selected tag' do
          tagged_exhibit.update!(weight: 1)
          untagged_exhibit.update!(weight: 2)
          later_match = FactoryBot.create(:exhibit, title: 'Some Later Title', tag_list: ['a'], weight: 3)
          allow(Spotlight::Exhibit).to receive(:default_per_page).and_return(1)

          get :index, params: { q: 'some', tag: 'a', page: 2 }

          expect(assigns(:published_exhibits)).to eq [later_match]
          expect(assigns(:published_exhibits).total_count).to eq 2
        end

        it 'filters the published exhibits with the configured search class' do
          tag_search_class = Class.new(Spotlight::ExhibitSearch) do
            def searchable_text(exhibit)
              exhibit.tag_list.join(' ')
            end
          end
          allow(Spotlight::Engine.config).to receive(:exhibit_search_class).and_return(-> { tag_search_class })
          history_exhibit = FactoryBot.create(:exhibit, tag_list: ['history'])

          get :index, params: { q: 'history' }

          expect(assigns(:published_exhibits)).to eq [history_exhibit]
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

    describe 'GET index' do
      let!(:matching_exhibit) { FactoryBot.create(:exhibit, title: 'Some Exhibit Title', published: false) }

      before { FactoryBot.create(:exhibit, title: 'Other Title', published: false) }

      it 'assigns the unpublished exhibits that match the search query' do
        get :index, params: { q: 'some' }
        expect(assigns(:unpublished_exhibits)).to eq [matching_exhibit]
      end
    end

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
  end

  describe 'when signed in as an exhibit admin' do
    let(:user) { FactoryBot.create(:exhibit_admin, exhibit:) }

    before { sign_in user }

    describe 'GET index' do
      let(:matching_exhibit) { FactoryBot.create(:exhibit, title: 'Some Exhibit Title') }

      before { user.roles.create(role: 'admin', resource: matching_exhibit) }

      it 'assigns the exhibits of the user that match the search query' do
        get :index, params: { q: 'some' }
        expect(assigns(:user_exhibits)).to eq [matching_exhibit]
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
        expect_any_instance_of(Spotlight::Exhibit).to receive(:reindex_later).and_return(true)
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
end
