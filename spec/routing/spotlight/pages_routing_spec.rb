require "spec_helper"

module Spotlight
  describe "FeaturePagesController and AboutPagesController" do
    describe "routing" do
      routes { Spotlight::Engine.routes }

      it "routes to #index" do
        get("/1/feature").should route_to("spotlight/feature_pages#index", exhibit_id: '1')
        get("/1/about").should   route_to("spotlight/about_pages#index",   exhibit_id: '1')
      end

      it "routes to #new" do
        get("/1/feature/new").should route_to("spotlight/feature_pages#new", exhibit_id: '1')
        get("/1/about/new").should   route_to("spotlight/about_pages#new",   exhibit_id: '1')
      end

      it "routes to #show" do
        get("/1/feature/2").should route_to("spotlight/feature_pages#show", id: "2", exhibit_id: "1")
        get("/1/about/2").should   route_to("spotlight/about_pages#show",   id: "2", exhibit_id: "1")
      end

      it "routes to #edit" do
        get("/1/feature/2/edit").should route_to("spotlight/feature_pages#edit", id: "2", exhibit_id: "1")
        get("/1/about/2/edit").should   route_to("spotlight/about_pages#edit",   id: "2", exhibit_id: "1")
      end

      it "routes to #create" do
        post("/1/feature").should route_to("spotlight/feature_pages#create", exhibit_id: '1')
        post("/1/about").should   route_to("spotlight/about_pages#create",   exhibit_id: '1')
      end

      it "routes to #update" do
        put("/1/feature/2").should route_to("spotlight/feature_pages#update", id: "2", exhibit_id: "1")
        put("/1/about/2").should   route_to("spotlight/about_pages#update",   id: "2", exhibit_id: "1")
      end

      it "routes to #destroy" do
        delete("/1/feature/2").should route_to("spotlight/feature_pages#destroy", id: "2", exhibit_id: "1")
        delete("/1/about/2").should   route_to("spotlight/about_pages#destroy",   id: "2", exhibit_id: "1")
      end

    end
  end
end
