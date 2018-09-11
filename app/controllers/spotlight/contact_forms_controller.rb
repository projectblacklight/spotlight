module Spotlight
  ##
  # Controller for routing exhibit feedback from users
  class ContactFormsController < Spotlight::ApplicationController
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
    before_action :build_contact_form

    def new
      @contact_form.current_url = request.referer
    end

    def create
      if @contact_form.valid?
        ContactMailer.report_problem(@contact_form).deliver_now

        redirect_back fallback_location: spotlight.new_exhibit_contact_form_path(current_exhibit), notice: t(:'helpers.submit.contact_form.created')
      else
        render 'new'
      end
    end

    protected

    def build_contact_form
      @contact_form = Spotlight::ContactForm.new(contact_form_params)
      @contact_form.current_exhibit = current_exhibit
      @contact_form.request = request
      @contact_form
    end

    def contact_form_params
      return {} if params[:action] == 'new'

      params.require(:contact_form).permit(:name, :email, Spotlight::Engine.config.spambot_honeypot_email_field, :message, :current_url)
    end
  end
end
