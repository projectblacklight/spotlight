module Spotlight
  # Create and update languages for an exhibit
  class LanguagesController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :exhibit, class: 'Spotlight::Exhibit'
    load_and_authorize_resource through: :exhibit

    # This is being done in a before action to de-couple the Page creation from Language creation.
    # A language can be created in tests, console, etc. w/o necessarily requiring an associated page is created.
    # This ties the home page creation explicitly to the action in the dashboard.
    before_action only: :create do
      @cloned_home_page = CloneTranslatedPageFromLocale.call(
        locale: @language.locale,
        page: @language.exhibit.home_page
      )
      @cloned_home_page.published = true
    end

    def create
      if @language.save && @cloned_home_page.save
        flash[:notice] = t('helpers.submit.language.created', model: @language.model_name.human.downcase)
      else
        flash[:alert] = [
          @language.errors.full_messages,
          @cloned_home_page.errors.full_messages
        ].join('<br/>'.html_safe)
      end
      redirect_to spotlight.edit_exhibit_path @exhibit, tab: 'language'
    end

    def destroy
      @language.destroy

      redirect_to(
        spotlight.edit_exhibit_path(@exhibit, tab: 'language'),
        notice: t(:'helpers.submit.language.destroyed', model: @language.model_name.human.downcase)
      )
    end

    private

    def create_params
      params.require(:language).permit(:locale)
    end
  end
end
