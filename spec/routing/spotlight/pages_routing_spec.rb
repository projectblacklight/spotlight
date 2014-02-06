require "spec_helper"

module Spotlight
  describe "FeaturePagesController and AboutPagesController" do
    describe "routing" do
      routes { Spotlight::Engine.routes }

      it "routes to #index" do
        get("/exhibits/1/feature").should route_to("spotlight/feature_pages#index", exhibit_id: '1')
        get("/exhibits/1/about").should   route_to("spotlight/about_pages#index",   exhibit_id: '1')
      end

      it "routes to #new" do
        get("/exhibits/1/feature/new").should route_to("spotlight/feature_pages#new", exhibit_id: '1')
        get("/exhibits/1/about/new").should   route_to("spotlight/about_pages#new",   exhibit_id: '1')
      end

      it "routes to #show" do
        get("/feature/2").should route_to("spotlight/feature_pages#show", id: "2")
        get("/about/2").should   route_to("spotlight/about_pages#show",   id: "2")
      end

      it "routes to #edit" do
        get("/feature/2/edit").should route_to("spotlight/feature_pages#edit", id: "2")
        get("/about/2/edit").should   route_to("spotlight/about_pages#edit",   id: "2")
      end

      it "routes to #create" do
        post("/exhibits/1/feature").should route_to("spotlight/feature_pages#create", exhibit_id: '1')
        post("/exhibits/1/about").should   route_to("spotlight/about_pages#create",   exhibit_id: '1')
      end

      it "routes to #update" do
        put("/feature/2").should route_to("spotlight/feature_pages#update", id: "2")
        put("/about/2").should   route_to("spotlight/about_pages#update",   id: "2")
      end

      it "routes to #destroy" do
        delete("/feature/2").should route_to("spotlight/feature_pages#destroy", id: "2")
        delete("/about/2").should   route_to("spotlight/about_pages#destroy",   id: "2")
      end

    end
  end
end
