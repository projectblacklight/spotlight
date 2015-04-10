module Spotlight
  ##
  # CRUD actions for exhibit curator contacts (not to be confused with
  # email addresses for receiving feedback messages, see {Spotlight::ExhibitsController})
  class ContactsController < Spotlight::ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :exhibit, class: 'Spotlight::Exhibit'
    load_and_authorize_resource through: :exhibit
    before_action :attach_breadcrumbs

    def new
      add_breadcrumb t(:'helpers.action.spotlight/contact.create'), new_exhibit_contact_path(@exhibit)
    end

    def edit
      add_breadcrumb @contact.name, edit_exhibit_contact_path(@contact.exhibit, @contact)
    end

    def update
      if @contact.update(contact_params)
        redirect_to exhibit_about_pages_path(@contact.exhibit), notice: t(:'helpers.submit.contact.updated', model: @contact.class.model_name.human.downcase)
      else
        render 'edit'
      end
    end

    def create
      if @contact.update(contact_params)
        redirect_to exhibit_about_pages_path(@contact.exhibit), notice: t(:'helpers.submit.contact.created', model: @contact.class.model_name.human.downcase)
      else
        render 'new'
      end
    end

    def destroy
      @contact.destroy
      redirect_to exhibit_about_pages_path(@contact.exhibit), notice: t(:'helpers.submit.contact.destroyed', model: @contact.class.model_name.human.downcase)
    end

    protected

    def attach_breadcrumbs
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.pages.index.about_pages.header'), exhibit_about_pages_path(@exhibit)
    end

    def contact_params
      params.require(:contact).permit(:name,
                                      :avatar,
                                      :avatar_crop_x,
                                      :avatar_crop_y,
                                      :avatar_crop_w,
                                      :avatar_crop_h,
                                      contact_info: Spotlight::Contact.fields.keys)
    end
  end
end
