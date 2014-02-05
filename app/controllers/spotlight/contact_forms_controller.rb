module Spotlight
  class ContactFormsController < Spotlight::ApplicationController
    def new
      @contact_form = Spotlight::ContactForm.new :current_url => request.referer
    end

    def create
      @contact_form = Spotlight::ContactForm.new(contact_form_params)
      @contact_form.request = request

      if @contact_form.valid?
        @contact_form.deliver
        render 'show'
      else
        render 'new' 
      end
      
    end

    protected
    def contact_form_params
      params.require(:contact_form).permit(:name, :email, :message, :current_url)
    end
  end
end