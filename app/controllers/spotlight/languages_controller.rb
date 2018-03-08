module Spotlight
  # Create and update languages for an exhibit
  class LanguagesController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :exhibit, class: 'Spotlight::Exhibit'
    load_and_authorize_resource through: :exhibit

    def create
      if @language.save
        flash[:notice] = t('helpers.submit.language.created', model: @language.model_name.human.downcase)
      else
        flash[:alert] = @language.errors.full_messages.join('<br/>'.html_safe)
      end
      redirect_to spotlight.edit_exhibit_path @exhibit, anchor: 'language'
    end

    def destroy
      @language.destroy

      redirect_to(
        spotlight.edit_exhibit_path(@exhibit, anchor: 'language'),
        notice: t(:'helpers.submit.language.destroyed', model: @language.model_name.human.downcase)
      )
    end

    private

    def create_params
      params.require(:language).permit(:locale)
    end
  end
end
