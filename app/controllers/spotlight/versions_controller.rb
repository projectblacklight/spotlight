module Spotlight
  ##
  # Controller for reverting to historical versions of e.g. pages
  class VersionsController < Spotlight::ApplicationController
    before_action :authenticate_user!

    load_and_authorize_resource class: 'PaperTrail::Version'

    def revert
      obj = @version.reify
      if obj && authorize!(:manage, obj)
        if obj.save
          redirect_to [obj.exhibit, obj], flash: { html_safe: true }, notice: undo_link
        else
          redirect_to [obj.exhibit, obj], flash: { html_safe: true }, notice: view_context.t(:'spotlight.versions.undo_error')
        end
      else
        redirect_to :back, flash: { html_safe: true }, notice: view_context.t(:'spotlight.versions.undo_error')
      end
    end

    private

    def undo_link
      return unless can? :manage, @version

      link_name = if params[:redo] == 'true'
                    view_context.t(:'spotlight.versions.undo')
                  else
                    view_context.t(:'spotlight.versions.redo')
                  end

      view_context.link_to(link_name, revert_version_path(@version.next, redo: !params[:redo]), method: :post)
    end
  end
end
