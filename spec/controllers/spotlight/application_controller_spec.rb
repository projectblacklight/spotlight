require 'spec_helper'

describe Spotlight::ApplicationController do
  routes { Spotlight::Engine.routes }
  it "should provide a search_action_url override" do
    controller.stub(current_exhibit: Spotlight::Exhibit.default)
    expect(controller.search_action_url(q: 'query')).to eq exhibit_catalog_index_url(Spotlight::Exhibit.default, q: "query")

  end
end