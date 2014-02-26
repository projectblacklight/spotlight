require "spec_helper"

module Spotlight
  describe "Catalog controller" do
    describe "routing" do
      routes { Spotlight::Engine.routes }

      it "routes to #edit" do
        get("/1/catalog/dq287tq6352/edit").should route_to("spotlight/catalog#edit", exhibit_id: '1', id: 'dq287tq6352')
      end
    end
  end
end
