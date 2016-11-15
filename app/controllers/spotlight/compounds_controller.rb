module Spotlight
  ##
  # Spotlight's compound controller. Used for creating and updating compound objects
  class CompoundsController < Spotlight::ApplicationController
    include Blacklight::SearchHelper
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit, prepend: true
    before_action :authenticate_user!, only: [:new, :create, :update, :edit]
    before_action :check_authorization, only: [:new, :create, :update, :edit]
    require 'fileutils'

    def index
      @exhibit = Spotlight::Exhibit.find params[:exhibit_id]
      @resources = Spotlight::Resources::Compound.where(exhibit_id: @exhibit)
      @documents = []
      @resources.each do |r|
        _resp, doc = fetch r.compound_id
        @documents << doc
      end
    rescue
      @resources = nil
    end

    def new
      @exhibit = Spotlight::Exhibit.find params[:exhibit_id]
    end

    def create
      @exhibit = Spotlight::Exhibit.find(params[:exhibit_id])
      @resource = Spotlight::Resources::Compound.new(exhibit: @exhibit, data: params[:data].to_hash)
      load_and_save
      redirect_to admin_exhibit_catalog_path(@exhibit), notice: 'compound object created successfully'
    rescue
      redirect_to new_exhibit_compound_path(@exhibit), alert: 'There was an error: compound object was not created'
    end

    def edit
      @exhibit = Spotlight::Exhibit.find params[:exhibit_id]
      @resource = Spotlight::Resource.find(params[:id].split('-').first.to_i)
    end

    def update
      @exhibit = Spotlight::Exhibit.find params[:exhibit_id]
      @resource = Spotlight::Resource.find(params[:id].split('-').last.to_i)
      load_and_save
      redirect_to exhibit_dashboard_path(@exhibit), notice: 'compound object updated successfully'
    rescue
      redirect_to exhibit_dashboard_path(@exhibit), alert: 'compound object was not updated'
    end

    protected

    def load_and_save
      @resource.data = params[:data].to_hash
      thumb_resource = Spotlight::Resource.find(params[:data][:items].first.split('-').last)
      @resource.url = File.open(thumb_resource.url.file.file)
      @resource.save!
      @resource.sidecar.data['configured_fields'] = params[:data].to_hash
      @resource.sidecar.save
      @resource.save_and_index
    end

    def check_authorization
      authorize! :curate, @exhibit
    end
  end
end
