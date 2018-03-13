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
      can [:update, :import, :export, :destroy], Spotlight::Exhibit, id: user.admin_roles.pluck(:resource_id)
      can :manage, [Spotlight::BlacklightConfiguration, Spotlight::ContactEmail, Spotlight::Language], exhibit_id: user.admin_roles.pluck(:resource_id)
      can :manage, Spotlight::Role, resource_id: user.admin_roles.pluck(:resource_id), resource_type: 'Spotlight::Exhibit'

      can :manage, PaperTrail::Version if user.roles.any?

      # exhibit curator
      can :manage, [
        Spotlight::Attachment,
        Spotlight::Search,
        Spotlight::Resource,
        Spotlight::Page,
        Spotlight::Contact,
        Spotlight::CustomField,
        Translation
      ], exhibit_id: user.exhibit_roles.pluck(:resource_id)

      can :manage, Spotlight::Lock, by: user

      can :read, Spotlight::Language, exhibit_id: user.exhibit_roles.pluck(:resource_id)
      can [:read, :curate, :tag], Spotlight::Exhibit, id: user.exhibit_roles.pluck(:resource_id)

      # public
      can :read, Spotlight::HomePage
      can :read, Spotlight::Exhibit, published: true
      can :read, Spotlight::Page, published: true
      can :read, Spotlight::Search, published: true
      can :read, Spotlight::Language, public: true
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
