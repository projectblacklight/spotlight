module Spotlight
  class ContactsController < Spotlight::ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource :exhibit, class: "Spotlight::Exhibit",  only: [:new, :create]
    load_and_authorize_resource through: :exhibit, shallow: true
    before_filter :attach_breadcrumbs

    def new
      add_breadcrumb t(:'helpers.action.spotlight/contact.create'), new_exhibit_contact_path(@exhibit)
    end

    def edit
      add_breadcrumb @contact.name, edit_exhibit_contact_path(@contact.exhibit, @contact)
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

    def attach_breadcrumbs
      load_exhibit
      add_breadcrumb @exhibit.title, @exhibit
      add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.pages.index.about_pages.header'), exhibit_about_pages_path(@exhibit)
    end

    def load_exhibit
      @exhibit ||= @contact.exhibit
    end

    def contact_params
      params.require(:contact).permit(:name, :email, :location, :title)
    end
  end
end
