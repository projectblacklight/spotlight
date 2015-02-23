module Spotlight::Ability
  include CanCan::Ability

  def initialize(user)
    user ||= ::User.new

    alias_action :process_import, to: :import
    alias_action :edit_metadata_fields, :edit_facet_fields, :edit_sort_fields, :metadata_fields, :available_search_views, to: :update

    if user.superadmin?
      can :manage, :all
    end

    # exhibit admin 
    can [:update, :import, :export, :destroy], Spotlight::Exhibit, id: user.admin_roles.pluck(:exhibit_id)
    can :manage, Spotlight::Role, exhibit_id: user.admin_roles.pluck(:exhibit_id)
    can :update, Spotlight::Appearance, exhibit_id: user.admin_roles.pluck(:exhibit_id)

    if user.roles.any?
      can :manage, PaperTrail::Version
    end

    # exhibit curator
    can :manage, [
      Spotlight::Attachment,
      Spotlight::Search,
      Spotlight::Resource,
      Spotlight::Page,
      Spotlight::Contact,
      Spotlight::CustomField], exhibit_id: user.roles.pluck(:exhibit_id)

    can :manage, Spotlight::Lock, by: user

    can :update, Spotlight::BlacklightConfiguration, exhibit_id: user.roles.pluck(:exhibit_id)

    can [:read, :curate, :tag], Spotlight::Exhibit, id: user.roles.pluck(:exhibit_id)

    # public
    can :read, Spotlight::HomePage
    can :read, Spotlight::Exhibit, published: true
    can :read, Spotlight::Page, published: true
    can :read, Spotlight::Search, on_landing_page: true

  end
end
