require "spec_helper"

module Spotlight
  describe PagesController do
    describe "routing" do
      routes { Spotlight::Engine.routes }

      it "routes to #index" do
        get("/exhibits/1/pages").should route_to("spotlight/pages#index", exhibit_id: '1')
      end

      it "routes to #new" do
        get("/exhibits/1/pages/new").should route_to("spotlight/pages#new", exhibit_id: '1')
      end

      it "routes to #show" do
        get("/pages/1").should route_to("spotlight/pages#show", :id => "1")
      end

      it "routes to #edit" do
        get("/pages/1/edit").should route_to("spotlight/pages#edit", :id => "1")
      end

      it "routes to #create" do
        post("/exhibits/1/pages").should route_to("spotlight/pages#create", exhibit_id: '1')
      end

      it "routes to #update" do
        put("/pages/1").should route_to("spotlight/pages#update", :id => "1")
      end

      it "routes to #destroy" do
        delete("/pages/1").should route_to("spotlight/pages#destroy", :id => "1")
      end

    end
  end
end
