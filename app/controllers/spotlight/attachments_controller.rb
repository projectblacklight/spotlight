require_dependency "spotlight/application_controller"

module Spotlight
  class AttachmentsController < ApplicationController
    before_filter :authenticate_user!
    load_resource :exhibit, class: "Spotlight::Exhibit", only: [:index, :create, :update_all]
    load_resource through: :exhibit


    # GET /attachments
    def index
      @attachments = Attachment.all
    end

    # GET /attachments/1
    def show
    end

    # GET /attachments/new
    def new
      @attachment = Attachment.new
    end

    # GET /attachments/1/edit
    def edit
    end

    # POST /attachments
    def create
      @attachment = Attachment.new(attachment_params)
 
      if @attachment.save
        render :json => @attachment
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /attachments/1
    def update
      if @attachment.update(attachment_params)
        redirect_to [@attachment.exhibit, @attachment], notice: 'Attachment was successfully updated.'
      else
        render action: 'edit'
      end
    end

    # DELETE /attachments/1
    def destroy
      @attachment.destroy
      redirect_to root_url, notice: 'Attachment was successfully destroyed.'
    end

    private

      # Only allow a trusted parameter "white list" through.
      def attachment_params
        params.require(:attachment).permit(:name, :file, :uid)
      end
  end
end
