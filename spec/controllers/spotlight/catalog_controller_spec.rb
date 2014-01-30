require 'spec_helper'

describe Spotlight::CatalogController do
  routes { Spotlight::Engine.routes }
  it "should show all the items" do
    get :index
    expect(response).to be_successful
    expect(assigns[:document_list]).to be_a Array
    expect(response).to render_template "spotlight/catalog/index"
  end
end
