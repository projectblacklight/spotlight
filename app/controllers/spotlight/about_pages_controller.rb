module Spotlight
  class AboutPagesController < PagesController
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit, only: :update_contacts

    def update_contacts
      if @exhibit.update(contact_params)
        redirect_to exhibit_about_pages_path(@exhibit), notice: 'Contacts were successfully updated.'
      else
        render action: 'index'
      end
    end

    protected

    def attach_breadcrumbs
      return if action_name == 'update_contacts'
      super
      if @page
        add_breadcrumb t(:'spotlight.about_pages.nav_link'), @exhibit.main_about_page
        add_breadcrumb @page.title, @page unless @page == @exhibit.main_about_page
      end
    end

    def contact_params
      params.require(:exhibit).permit("contacts_attributes" => [:id, :show_in_sidebar, :weight])
    end
  end
end
