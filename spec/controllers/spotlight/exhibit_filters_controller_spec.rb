require 'spec_helper'

describe Spotlight::ExhibitFiltersController do
  routes { Spotlight::Engine.routes }

  describe '#update' do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    let(:exhibit_filter) { exhibit.exhibit_filters.first }

    context 'when not signed in' do
      it 'is successful' do
        patch :update, exhibit_id: exhibit, id: exhibit_filter, exhibit_filters: { field: 'foo_ssi', value: 'bar_ssi' }
        expect(:response).to redirect_to main_app.new_user_session_path
      end
    end

    context 'when signed in as a site admin' do
      before { sign_in user }
      let(:user) { FactoryGirl.create(:site_admin) }

      it 'is successful' do
        patch :update, exhibit_id: exhibit, id: exhibit_filter, exhibit_filter: { field: 'foo_ssi', value: 'bar' }
        expect(:response).to redirect_to edit_exhibit_path(exhibit, anchor: 'filter')
        expect(assigns[:exhibit].solr_data).to eq('foo_ssi' => 'bar')
      end
    end
  end
end
