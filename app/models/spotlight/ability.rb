module Spotlight::Ability
  include CanCan::Ability

  def initialize(user)
    user ||= ::User.new
    
    # This is the "right" way to do it. But it doesn't work in rails 4
    # until this PR is merged: https://github.com/ryanb/cancan/pull/917
    # can :create, Spotlight::Exhibit, admin_roles: { id: user.role_ids } 
    # Until then, workaround:
    can :update, Spotlight::Exhibit, id: user.admin_roles.map(&:exhibit_id)

    can [:index, :update, :destroy, :create], Spotlight::Role, exhibit_id: user.admin_roles.map(&:exhibit_id)


    can [:update, :edit_metadata_fields, :edit_facet_fields], Spotlight::BlacklightConfiguration do |config|
      config.exhibit.roles.where(id: user.role_ids).any?
    end

    can :manage, Spotlight::CustomField do |config|
      config.exhibit.roles.where(id: user.role_ids).any?
    end

    can [:curate, :tag], Spotlight::Exhibit do |exhibit|
      # any curator or admin role
      exhibit.roles.where(id: user.role_ids).any?
    end

    can [:read, :index], [Spotlight::Exhibit, Spotlight::Page, Spotlight::Search]

    # any curator or admin role
    if Spotlight::Exhibit.default.roles.where(id: user.role_ids).any?
      can [:create, :update, :destroy], [Spotlight::Search, Spotlight::Page]
      can :update_all, [Spotlight::Search, Spotlight::Page] #TODO make these specific to the owning exhibit
      can [:update], ::SolrDocument
    end
  end
end
