module Spotlight
  ##
  # CRUD actions for about pages and contacts
  class AboutPagesController < PagesController
    load_and_authorize_resource through: :exhibit, instance_name: 'page'
    before_action :attach_breadcrumbs, except: [:update_contacts]

    def update_contacts
      if @exhibit.update(contact_params)
        redirect_to exhibit_about_pages_path(@exhibit), notice: t(:'helpers.submit.contact.batch_updated')
      else
        render action: 'index'
      end
    end

    protected

    def attach_breadcrumbs
      super
      if @page
        attach_section_breadcrumbs
        attach_page_breadcrumbs
      elsif action_name == 'index'
        add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
        add_breadcrumb t(:'spotlight.pages.index.about_pages.header'), exhibit_about_pages_path(@exhibit)
      end
    end

    def attach_page_breadcrumbs
      return if @page == @exhibit.main_about_page

      if action_name == 'edit'
        add_breadcrumb @page.title, [:edit, @page.exhibit, @page]
      else
        add_breadcrumb @page.title, [@page.exhibit, @page]
      end
    end

    def attach_section_breadcrumbs
      if action_name == 'edit'
        add_breadcrumb t(:'spotlight.pages.index.about_pages.header'), exhibit_about_pages_path(@exhibit)
      else
        add_breadcrumb((@exhibit.main_navigations.about.label_or_default), [@exhibit, @exhibit.main_about_page])
      end
    end

    def contact_params
      params.require(:exhibit).permit('contacts_attributes' => [:id, :show_in_sidebar, :weight])
    end

    def update_all_page_params
      params.require(:exhibit).permit('about_pages_attributes' => page_attributes)
    end

    def allowed_page_params
      super.concat [:published]
    end
  end
end
