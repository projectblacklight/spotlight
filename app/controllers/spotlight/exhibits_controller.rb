# frozen_string_literal: true

module Spotlight
  ##
  # Administrative CRUD actions for an exhibit
  class ExhibitsController < Spotlight::ApplicationController
    include Spotlight::SearchHelper

    before_action :authenticate_user!, except: [:index]
    before_action :set_tab, only: %i[edit update]

    load_and_authorize_resource

    def index
      @exhibit_search = Spotlight::ExhibitSearch.new(params[:q])
      @published_exhibits = paginate(published_exhibits)
      @unpublished_exhibits = @exhibit_search.filter(unpublished_exhibits)
      @user_exhibits = @exhibit_search.filter(current_user.exhibits) if current_user
      if @exhibits.one?
        redirect_to @exhibits.first, flash: flash.to_h
      else
        render layout: 'spotlight/home'
      end
    end

    def show
      respond_to do |format|
        format.json do
          authorize! :export, @exhibit
          send_data JSON.pretty_generate(Spotlight::ExhibitImportExportService.new(@exhibit).as_json),
                    type: 'application/json',
                    disposition: 'attachment',
                    filename: "#{@exhibit.friendly_id}-export.json"
        end
      end
    end

    def new
      build_initial_exhibit_contact_emails
      add_breadcrumb(t(:'spotlight.sites.home'), root_url)
      add_breadcrumb(t(:'spotlight.exhibits.new.page_title'))
    end

    def process_import
      if @exhibit.import(JSON.parse(import_exhibit_params.read)) && @exhibit.reindex_later(current_user)
        redirect_to spotlight.exhibit_dashboard_path(@exhibit), notice: t(:'helpers.submit.exhibit.updated', model: @exhibit.class.model_name.human.downcase)
      else
        render action: :import
      end
    end

    def edit
      add_breadcrumb(t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit)
      add_breadcrumb(t(:'spotlight.configuration.sidebar.header'), exhibit_dashboard_path(@exhibit))
      add_breadcrumb(t(:'spotlight.configuration.sidebar.settings'), edit_exhibit_path(@exhibit))
      build_initial_exhibit_contact_emails
    end

    # rubocop:disable Metrics/AbcSize
    def create
      @exhibit.attributes = exhibit_params

      if @exhibit.save
        @exhibit.roles.create user: current_user, role: 'admin' if current_user
        redirect_to spotlight.exhibit_dashboard_path(@exhibit), notice: t(:'helpers.submit.exhibit.created', model: @exhibit.class.model_name.human.downcase)
      else
        flash.now[:alert] = t('spotlight.exhibits.new_exhibit_form.errors.slug_taken') if @exhibit.errors[:slug].present?

        render :new, status: :unprocessable_content
      end
    end
    # rubocop:enable Metrics/AbcSize

    def update
      if @exhibit.update(exhibit_params)
        redirect_to edit_exhibit_path(@exhibit, tab: @tab),
                    notice: t(:'helpers.submit.exhibit.updated',
                              model: @exhibit.class.model_name.human.downcase)
      else
        flash[:alert] = @exhibit.errors.full_messages.join('<br>'.html_safe)
        render action: :edit
      end
    end

    def destroy
      @exhibit.destroy

      redirect_to main_app.root_url, notice: t(:'helpers.submit.exhibit.destroyed', model: @exhibit.class.model_name.human.downcase)
    end

    def current_exhibit
      @exhibit if @exhibit&.persisted?
    end

    protected

    def published_exhibits
      exhibits = @exhibits.includes(:thumbnail).published.ordered_by_weight
      return search_published_exhibits(exhibits) if @exhibit_search.active?

      params[:tag].present? ? exhibits.tagged_with(params[:tag]) : exhibits
    end

    def search_published_exhibits(exhibits)
      matches = @exhibit_search.filter(exhibits.includes(:tags))
      # Tag availability includes matches outside the selected tag and the current page.
      @matching_tag_names = matches.flat_map { |exhibit| exhibit.tags.map(&:name) }.uniq
      return matches if params[:tag].blank?

      tagged_ids = exhibits.tagged_with(params[:tag]).pluck(:id).to_set
      matches.select { |exhibit| tagged_ids.include?(exhibit.id) }
    end

    def unpublished_exhibits
      @exhibits.unpublished.ordered_by_weight.accessible_by(current_ability)
    end

    def paginate(exhibits)
      return exhibits.page(params[:page]) unless @exhibit_search.active?

      Kaminari.paginate_array(exhibits).page(params[:page]).per(Spotlight::Exhibit.default_per_page)
    end

    def exhibit_params
      params.require(:exhibit).permit(
        :title,
        :subtitle,
        :description,
        :published,
        :tag_list,
        tag_list: [],
        contact_emails_attributes: %i[id email],
        languages_attributes: %i[id public]
      )
    end

    def set_tab
      @tab = params[:tab]
    end

    def create_params
      params.require(:exhibit).permit(
        :title,
        :slug
      ).reject { |_k, v| v.blank? }
    end

    def import_exhibit_params
      params.require(:file)
    end

    def build_initial_exhibit_contact_emails
      @exhibit.contact_emails.build if @exhibit.contact_emails.blank?
    end
  end
end
