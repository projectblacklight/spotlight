require 'spec_helper'

describe Spotlight::ApplicationController do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  it "should provide a search_action_url override" do
    controller.stub(current_exhibit: exhibit)
    expect(controller.search_action_url(q: 'query')).to eq exhibit_catalog_index_url(exhibit, q: "query")
  end
end
