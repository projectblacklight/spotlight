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
        get("/exhibits/1/feature/2").should route_to("spotlight/feature_pages#show", exhibit_id: "1", id: "2")
        get("/exhibits/1/about/2").should   route_to("spotlight/about_pages#show",   exhibit_id: "1", id: "2")
      end

      it "routes to #edit" do
        get("/exhibits/1/feature/2/edit").should route_to("spotlight/feature_pages#edit", exhibit_id: "1", id: "2")
        get("/exhibits/1/about/2/edit").should   route_to("spotlight/about_pages#edit",   exhibit_id: "1", id: "2")
      end

      it "routes to #create" do
        post("/exhibits/1/feature").should route_to("spotlight/feature_pages#create", exhibit_id: '1')
        post("/exhibits/1/about").should   route_to("spotlight/about_pages#create",   exhibit_id: '1')
      end

      it "routes to #update" do
        put("/exhibits/1/feature/2").should route_to("spotlight/feature_pages#update", exhibit_id: "1", id: "2")
        put("/exhibits/1/about/2").should   route_to("spotlight/about_pages#update",   exhibit_id: "1", id: "2")
      end

      it "routes to #destroy" do
        delete("/exhibits/1/feature/2").should route_to("spotlight/feature_pages#destroy", exhibit_id: "1", id: "2")
        delete("/exhibits/1/about/2").should   route_to("spotlight/about_pages#destroy",   exhibit_id: "1", id: "2")
      end

    end
  end
end
