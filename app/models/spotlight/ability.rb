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
      if (user.is_masked?) 
        if (user.masked_role.eql?('admin'))
          can [:update, :import, :export, :destroy], Spotlight::Exhibit
          can :manage, [Spotlight::BlacklightConfiguration, Spotlight::ContactEmail, Spotlight::Language]
          can :manage, Spotlight::Role, resource_type: 'Spotlight::Exhibit'
        end
      else
        can [:update, :import, :export, :destroy], Spotlight::Exhibit, id: user.admin_roles.pluck(:resource_id)
        can :manage, [Spotlight::BlacklightConfiguration, Spotlight::ContactEmail, Spotlight::Language], exhibit_id: user.admin_roles.pluck(:resource_id)
        can :manage, Spotlight::Role, resource_id: user.admin_roles.pluck(:resource_id), resource_type: 'Spotlight::Exhibit'
      end

      can :manage, PaperTrail::Version if user.roles.any?
      can :manage, FeaturedImage if user.roles.any?

      if (user.is_masked?)
          # exhibit curator
          can :manage, [
            Spotlight::Attachment,
            Spotlight::Search,
            Spotlight::Resource,
            Spotlight::Page,
            Spotlight::Contact,
            Spotlight::CustomField,
            Translation
          ]
      else
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
      end

      can :manage, Spotlight::Lock, by: user

      if (user.is_masked?) 
          can :read, Spotlight::Language
          can [:read, :curate, :tag], Spotlight::Exhibit
      else
        can :read, Spotlight::Language, exhibit_id: user.exhibit_roles.pluck(:resource_id)
        can [:read, :curate, :tag], Spotlight::Exhibit, id: user.exhibit_roles.pluck(:resource_id)
      end

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
