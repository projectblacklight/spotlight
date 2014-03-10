class Spotlight::ExhibitsController < Spotlight::ApplicationController
  before_filter :authenticate_user!
  include Blacklight::SolrHelper

  load_and_authorize_resource

  def new
  end

  def import
  end

  def process_import
    if @exhibit.import(JSON.parse(import_exhibit_params.read))
      redirect_to spotlight.exhibit_dashboard_path(@exhibit), notice: "The exhibit was successfully updated."
    else
      render action: :import
    end
  end

  def create
    @exhibit.attributes = exhibit_params

    if @exhibit.save
      redirect_to spotlight.exhibit_dashboard_path(@exhibit), notice: "The exhibit was created."
    else
      render action: :new
    end
  end

  def show
    respond_to do |format|
      format.json { send_data Spotlight::ExhibitExportSerializer.new(@exhibit).to_json, type: 'application/json', disposition: 'attachment', filename: "#{@exhibit.friendly_id}-export.json" }
    end
  end

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
      flash[:alert] = @exhibit.errors.full_messages.join("<br>".html_safe)
      render action: :edit
    end
  end

  def destroy
    @exhibit.destroy

    redirect_to main_app.root_url, notice: 'Exhibit was successfully destroyed.'
  end

  protected

  def current_exhibit
    @exhibit if @exhibit.persisted?
  end

  def exhibit_params
    params.require(:exhibit).permit(
      :title,
      :subtitle,
      :description,
      contact_emails_attributes: [:id, :email]
    )
  end

  def import_exhibit_params
    params.require(:file)
  end
end
