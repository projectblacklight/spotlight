# frozen_string_literal: true

module Spotlight
  # Mailer for contacting new exhibit curators or administrators
  class InvitationMailer < ActionMailer::Base
    include Devise::Mailers::Helpers

    def exhibit_invitation_notification(role)
      initialize_from_record(role.user)
      @role = role
      @key = if @role.resource.is_a?(Spotlight::Site)
               'exhibits_admin_invitation_mailer'
             else
               'invitation_mailer'
             end
      mail(to: role.user.email,
           from: mailer_sender(devise_mapping),
           subject: I18n.t("spotlight.#{@key}.invitation_instructions.subject", exhibit_name: @role.resource.title))
    end
  end
end
