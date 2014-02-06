module Spotlight
  class HomePagesController < Spotlight::PagesController
    def index
      redirect_to exhibit_feature_pages_path(@exhibit)
    end

    private
    def page_model
      :home_page
    end
    def cast_page_instance_variable
      if @home_pages
        @pages = @home_pages
      elsif @home_page
        @page = @home_page
      end
    end
  end
end