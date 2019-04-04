# frozen_string_literal: true

describe Spotlight::ApplicationController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  it 'provides a search_action_url override' do
    allow(controller).to receive_messages(current_exhibit: exhibit)
    expect(controller.search_action_url(q: 'query')).to eq search_exhibit_catalog_url(exhibit, q: 'query')
  end
end
