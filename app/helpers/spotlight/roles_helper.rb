module Spotlight
  ##
  # Exhibit roles helpers
  module RolesHelper
    ##
    # Format the available roles for a select_tag
    def roles_for_select
      Spotlight::Role::ROLES.each_with_object({}) do |key, object|
        object[t("spotlight.role.#{key}")] = key
      end
    end
  end
end
