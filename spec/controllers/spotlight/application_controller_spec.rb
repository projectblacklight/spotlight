require 'spec_helper'

describe Spotlight::ApplicationController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  it 'provides a search_action_url override' do
    allow(controller).to receive_messages(current_exhibit: exhibit)
    expect(controller.search_action_url(q: 'query')).to eq exhibit_catalog_index_url(exhibit, q: 'query')
  end
end
