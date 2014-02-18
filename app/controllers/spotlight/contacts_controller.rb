module Spotlight
  class ContactsController < Spotlight::ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource except: [:new, :create]
    load_and_authorize_resource :exhibit, class: "Spotlight::Exhibit",  only: [:new, :create]
    load_and_authorize_resource through: :exhibit, only: [:new, :create]

    def new
    end

    def edit
    end

    def update
      if @contact.update(contact_params)
        redirect_to exhibit_about_pages_path(@contact.exhibit), notice: "Contact updated."
      else
        render 'edit'
      end
    end

    def create
      if @contact.update(contact_params)
        redirect_to exhibit_about_pages_path(@contact.exhibit), notice: "Contact created."
      else
        render 'new'
      end
    end

    def destroy
      @contact.destroy
      redirect_to exhibit_about_pages_path(@contact.exhibit), notice: "Contact removed."
    end

    protected

    def contact_params
      params.require(:contact).permit(:name, :email, :location, :title)
    end
  end
end
