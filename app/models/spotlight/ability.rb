# frozen_string_literal: true

module Spotlight
  ##
  # Default Spotlight CanCan abilities
  module Ability
    include CanCan::Ability

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def initialize(user)
      user ||= Spotlight::Engine.user_class.new

      alias_action :process_import, to: :import

      can :manage, :all if user.superadmin?

      # exhibit admin
      can %i[update import export destroy], Spotlight::Exhibit, id: user.admin_roles.pluck(:resource_id)
      can :manage, [Spotlight::BlacklightConfiguration, Spotlight::ContactEmail, Spotlight::Language], exhibit_id: user.admin_roles.pluck(:resource_id)
      can :manage, Spotlight::Role, resource_id: user.admin_roles.pluck(:resource_id), resource_type: 'Spotlight::Exhibit'

      can :manage, [PaperTrail::Version, Spotlight::FeaturedImage] if user.exhibit_roles.any?

      # exhibit curator
      can :manage, [
        Spotlight::Attachment,
        Spotlight::Search,
        Spotlight::Group,
        Spotlight::Resource,
        Spotlight::Page,
        Spotlight::Contact,
        Spotlight::CustomField,
        Spotlight::CustomSearchField,
        Translation
      ], exhibit_id: user.exhibit_roles.pluck(:resource_id)

      can :read, Spotlight::JobTracker, on_id: user.exhibit_roles.pluck(:resource_id), on_type: 'Spotlight::Exhibit'

      can :manage, Spotlight::Lock, by: user

      can :read, Spotlight::Language, exhibit_id: user.exhibit_roles.pluck(:resource_id)
      can %i[read curate tag bulk_update], Spotlight::Exhibit, id: user.exhibit_roles.pluck(:resource_id)

      # public
      can :read, Spotlight::HomePage, published: true
      can :read, Spotlight::Exhibit, published: true
      can :read, Spotlight::Page, published: true
      can :read, Spotlight::Search, published: true
      can :read, Spotlight::Group, published: true
      can :read, Spotlight::Language, public: true

      can :read, Spotlight::Exhibit, id: user.viewer_roles.pluck(:resource_id)
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
