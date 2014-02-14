module Spotlight
  class FeaturePagesController < PagesController

    private
    def cast_page_instance_variable
      if @feature_pages
        @pages = @feature_pages
      elsif @feature_page
        @page = @feature_page
      end
    end

  end
end
