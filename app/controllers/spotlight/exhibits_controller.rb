class Spotlight::ExhibitsController < Spotlight::ApplicationController
  before_filter :authenticate_user!
  include Blacklight::SolrHelper

  load_and_authorize_resource

  def edit
    add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
    add_breadcrumb t(:'spotlight.administration.sidebar.header'), exhibit_dashboard_path(@exhibit)
    add_breadcrumb t(:'spotlight.administration.sidebar.settings'), edit_exhibit_path(@exhibit)
    @exhibit.contact_emails.build unless @exhibit.contact_emails.present?
  end

  def update
    if @exhibit.update(exhibit_params)
      redirect_to main_app.root_path, notice: "The exhibit was saved."
    else
      puts "ERROR #{@exhibit.errors.full_messages}"
      render action: :edit
    end
  end

  protected

  def exhibit_params
    params.require(:exhibit).permit(
      :title,
      :subtitle,
      :description,
      contact_emails_attributes: [:id, :email]
    )
  end
end
