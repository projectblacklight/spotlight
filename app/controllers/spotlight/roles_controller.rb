module Spotlight
  class RolesController < Spotlight::ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit, prepend: true
    load_and_authorize_resource through: :exhibit, except: [:update_all]

    def index
      role = @exhibit.roles.build
      authorize! :edit, role
      
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb t(:'spotlight.administration.sidebar.header'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.administration.sidebar.users'), exhibit_roles_path(@exhibit)
    end

    def update_all
      attrs = params.require(:exhibit).permit(:roles_attributes => [:id, :user_key, :role, :_destroy])

      any_deleted = authorize_nested_attributes(attrs[:roles_attributes], Role)

      if @exhibit.update(attrs)
        notice = any_deleted > 0 ? "User has been removed." : "User has been updated."
        redirect_to exhibit_roles_path(@exhibit), notice: notice 
      else
        flash[:alert] = "There was a problem saving the users."
        render action: 'index'
      end

    end

    protected


    # When nested attributes are passed in, ensure we have authorization to update each row.
    # @param attr [Hash,Array] the nested attributes
    # @param klass [Class] the class that is getting created
    # @return [Integer] a count of the number of deleted records
    def authorize_nested_attributes(attrs, klass)
      attrs = attrs.values if attrs.is_a? Hash
      delete_count = 0
      attrs.each do |item|
        if item[:id]
          if ActiveRecord::ConnectionAdapters::Column.value_to_boolean(item['_destroy'])
            authorize! :destroy, klass.find(item[:id])
            delete_count += 1
          else
            authorize! :update, klass.find(item[:id])
          end
        else
          authorize! :create, klass
        end
      end
      delete_count
    end

  end
end
