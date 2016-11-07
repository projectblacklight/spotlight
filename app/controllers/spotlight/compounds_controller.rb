module Spotlight
	class CompoundsController < Spotlight::ApplicationController
		include Blacklight::SearchHelper
		load_and_authorize_resource :exhibit, class: Spotlight::Exhibit, prepend: true
		before_action :authenticate_user!, only: [:new, :create, :update, :edit]
		before_action :check_authorization, only: [:new, :create, :update, :edit]
		require 'fileutils'
		
		def index
			@exhibit = Spotlight::Exhibit.find params[:exhibit_id]
			@resources = Spotlight::Resource.where("data like '%items%' and exhibit_id = '#{@exhibit.id}'")
			@documents = []
			@resources.each do |r|
				resp, doc = fetch "#{r.exhibit_id}-#{r.id}"
				@documents << doc
			end
		end
		
		def new
			@exhibit = Spotlight::Exhibit.find params[:exhibit_id]
		end
		
		def create
			begin
				@exhibit = Spotlight::Exhibit.find(params[:exhibit_id])
				@thumb_resource = Spotlight::Resource.find(params[:data][:items].first.split("-").last)
				@resource = Spotlight::Resources::Upload.new(exhibit: @exhibit, data: params[:data].to_hash)
				@resource[:url] = @thumb_resource[:url]
				@resource.save
				FileUtils.mkdir_p("public/#{@resource.url.store_dir}")
				copy_files
				@resource.sidecar.data["configured_fields"] = params[:data].to_hash
				@resource.sidecar.save
				@resource.save_and_index
				redirect_to "/spotlight/#{params[:exhibit_id]}/catalog/admin", notice: 'compound object created successfully'
			rescue => e
				redirect_to "/spotlight/#{params[:exhibit_id]}/compounds/new", alert: "There was an error: compound object was not created"
			end
		end
		
		def edit
			@exhibit = Spotlight::Exhibit.find params[:exhibit_id]
			@resource = Spotlight::Resource.find(params[:id].split('-').first.to_i)
		end
		
		def update
			begin
				@exhibit = Spotlight::Exhibit.find params[:exhibit_id]
				id = params[:id].split('-')[1].to_i
				@resource = Spotlight::Resource.find(id)
				@resource.data = params[:data].to_hash
				FileUtils.rm_rf(Dir.glob(@resource.url.file.file.dup.sub(@resource[:url], "*")))
				@thumb_resource = Spotlight::Resource.find(params[:data][:items].first.split("-").last)
				@resource[:url] = @thumb_resource[:url]
				copy_files
				@resource.sidecar.data["configured_fields"] = params[:data].to_hash
				@resource.sidecar.save
				@resource.save_and_index
				redirect_to "/spotlight/#{params[:exhibit_id]}/dashboard", notice: 'compound object updated successfully'
			rescue => e
				Rails.logger.warn(e.inspect)
				redirect_to "/spotlight/#{params[:exhibit_id]}/dashboard", alert: "compound object was not updated"
			end
		end
		
		def documents
			@documents
		end
		
		protected
		
		def copy_files
			new_url = @thumb_resource.url.file.file.to_s.dup.sub! "/"+@thumb_resource.id.to_s+"/", "/"+@resource.id.to_s+"/"
			FileUtils.cp(@thumb_resource.url.file.file, new_url)
			new_url = @thumb_resource.url.square.file.file.to_s.dup.sub! "/"+@thumb_resource.id.to_s+"/", "/"+@resource.id.to_s+"/"
			FileUtils.cp(@thumb_resource.url.square.file.file, new_url)
			new_url = @thumb_resource.url.thumb.file.file.to_s.dup.sub! "/"+@thumb_resource.id.to_s+"/", "/"+@resource.id.to_s+"/"
			FileUtils.cp(@thumb_resource.url.thumb.file.file, new_url)
		end
		
		
		def check_authorization
		  authorize! :curate, @exhibit
		end
	end
end