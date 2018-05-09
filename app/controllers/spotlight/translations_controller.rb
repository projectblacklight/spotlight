module Spotlight
  ##
  # Base CRUD controller for translations
  class TranslationsController < Spotlight::ApplicationController
    before_action :authenticate_user!, :set_language, :set_tab
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit

    def edit; end

    def update
      if current_exhibit.update(exhibit_params)
        I18n.reload! # reload since we're memoizing
        notice = t(:'helpers.submit.spotlight_default.updated', model: current_exhibit.class.model_name.human.downcase)
        redirect_to edit_exhibit_translations_path(current_exhibit, language: @language, tab: @tab), notice: notice
      else
        render 'edit'
      end
    end

    private

    def exhibit_params
      params.require(:exhibit).permit(translations_attributes: [:id, :locale, :key, :value])
    end

    def set_language
      @language = params[:language] || current_exhibit.available_locales.first
    end

    def set_tab
      @tab = params[:tab]
    end
  end
end
