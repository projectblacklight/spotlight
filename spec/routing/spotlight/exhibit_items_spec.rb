require "spec_helper"

module Spotlight
  describe "Items controller" do
    describe "routing" do
      routes { Spotlight::Engine.routes }

      it "routes to #show" do
        get("/exhibits/1/items/dq287tq6352").should route_to("spotlight/items#show", exhibit_id: '1', id: 'dq287tq6352')
      end
      it "routes to #edit" do
        get("/exhibits/1/items/dq287tq6352/edit").should route_to("spotlight/items#edit", exhibit_id: '1', id: 'dq287tq6352')
      end
    end
  end
end
