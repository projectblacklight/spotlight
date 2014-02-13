module Spotlight::RolesHelper
  def roles_for_select
    Spotlight::Role::ROLES.each_with_object({}) do |key, object|
      object[t("spotlight.role.#{key}")] = key
    end
  end
end
