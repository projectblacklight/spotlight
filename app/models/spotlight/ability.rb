module Spotlight::Ability
  include CanCan::Ability

  def initialize(user)
    user ||= ::User.new

    alias_action :process_import, to: :import
    alias_action :edit_metadata_fields, :edit_facet_fields, :metadata_fields, to: :update
    
    if user.superadmin?
      can :manage, :all
    end

    # exhibit admin 
    can [:update, :import, :destroy], Spotlight::Exhibit, id: user.admin_roles.pluck(:exhibit_id)
    can :manage, Spotlight::Role, exhibit_id: user.admin_roles.pluck(:exhibit_id)
    can :update, Spotlight::Appearance, exhibit_id: user.admin_roles.pluck(:exhibit_id)

    # exhibit curator
    can :manage, [
      Spotlight::Attachment,
      Spotlight::Search,
      Spotlight::Page,
      Spotlight::Contact,
      Spotlight::CustomField], exhibit_id: user.roles.pluck(:exhibit_id)

    can :update, Spotlight::BlacklightConfiguration, exhibit_id: user.roles.pluck(:exhibit_id)

    can [:curate, :tag], Spotlight::Exhibit, id: user.roles.pluck(:exhibit_id)

    # public
    can :read, [Spotlight::Exhibit, Spotlight::HomePage]
    can :read, Spotlight::Page, published: true
    can :read, Spotlight::Search, on_landing_page: true

  end
end
