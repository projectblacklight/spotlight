module Spotlight::Ability
  include CanCan::Ability

  def initialize(user)
    user ||= ::User.new
    
    if user.superadmin?
      can :manage, :all
    end

    # This is the "right" way to do it. But it doesn't work in rails 4
    # until this PR is merged: https://github.com/ryanb/cancan/pull/917
    # can :create, Spotlight::Exhibit, admin_roles: { id: user.role_ids } 
    # Until then, workaround:

    # exhibit admin 
    can :manage, Spotlight::Exhibit, id: user.admin_roles.pluck(:exhibit_id)
    can :manage, Spotlight::Role, exhibit_id: user.admin_roles.pluck(:exhibit_id)
    can :update, Spotlight::Appearance, exhibit_id: user.admin_roles.pluck(:exhibit_id)

    # exhibit curator
    can :manage, [
      Spotlight::Attachment,
      Spotlight::Search,
      Spotlight::Page,
      Spotlight::Contact,
      Spotlight::CustomField], exhibit_id: user.roles.pluck(:exhibit_id)

    can [:edit_metadata_fields, :edit_facet_fields, :metadata_fields, :update], Spotlight::BlacklightConfiguration, exhibit_id: user.roles.pluck(:exhibit_id)

    can [:curate, :tag], Spotlight::Exhibit, id: user.roles.pluck(:exhibit_id)

    # public
    can :read, [Spotlight::Exhibit,Spotlight::HomePage]
    can :read, Spotlight::Page, published: true
    can :read, Spotlight::Search, on_landing_page: true

  end
end
