module Spotlight
  class VersionsController < Spotlight::ApplicationController
    before_filter :authenticate_user!

    load_and_authorize_resource class: "PaperTrail::Version"

    def revert
      if obj = @version.reify
        authorize! :manage, obj
        if obj.save
          redirect_to [obj.exhibit, obj], flash: { html_safe: true }, notice: undo_link
        else
          redirect_to [obj.exhibit, obj], flash: { html_safe: true }, notice: view_context.t(:'spotlight.versions.undo_error')
        end
      else
        redirect_to :back, flash: { html_safe: true }, notice: view_context.t(:'spotlight.versions.undo_error')
      end

    end

    def undo_link
      return unless can? :manage, @version

      link_name = if params[:redo] == "true"
        view_context.t(:'spotlight.versions.undo')
      else
        view_context.t(:'spotlight.versions.redo')
      end

      view_context.link_to(link_name, revert_version_path(@version.next, :redo => !params[:redo]), method: :post)
    end
  end
end