module Spotlight
  ##
  # Base CRUD controller for translations
  class TranslationsController < Spotlight::ApplicationController
    before_action :authenticate_user!, :set_language
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit

    def edit; end

    def update
      if current_exhibit.update(translations_attributes: translations_attributes_destroying_blanks)
        I18n.reload! # reload since we're memoizing
        notice = t(:'helpers.submit.spotlight_default.updated', model: current_exhibit.class.model_name.human.downcase)
        redirect_to edit_exhibit_translations_path(current_exhibit, params: { language: @language }), notice: notice
      else
        render 'edit'
      end
    end

    private

    def translations_attributes_destroying_blanks
      exhibit_params.to_h[:translations_attributes].map do |index, attrs|
        attrs['_destroy'] = true if attrs['value'].blank?
        [index, attrs]
      end.to_h
    end

    def exhibit_params
      params.require(:exhibit).permit(translations_attributes: [:id, :locale, :key, :value])
    end

    def set_language
      @language = params[:language] || current_exhibit.available_locales.first
    end
  end
end
