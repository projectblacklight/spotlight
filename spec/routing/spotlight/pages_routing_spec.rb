require "spec_helper"

module Spotlight
  describe PagesController do
    describe "routing" do
      routes { Spotlight::Engine.routes }

      it "routes to #index" do
        get("/pages").should route_to("spotlight/pages#index")
      end

      it "routes to #new" do
        get("/pages/new").should route_to("spotlight/pages#new")
      end

      it "routes to #show" do
        get("/pages/1").should route_to("spotlight/pages#show", :id => "1")
      end

      it "routes to #edit" do
        get("/pages/1/edit").should route_to("spotlight/pages#edit", :id => "1")
      end

      it "routes to #create" do
        post("/pages").should route_to("spotlight/pages#create")
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
