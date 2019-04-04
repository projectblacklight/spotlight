# frozen_string_literal: true

describe Spotlight::InviteUsersService do
  subject { described_class.call(resource: resource) }

  let(:resource) do
    FactoryBot.create(:exhibit, roles: [FactoryBot.create(:role, user: user)])
  end

  context 'when the user was not created by an invite' do
    let(:user) { FactoryBot.create(:user) }

    it 'does not send an invite' do
      expect do
        subject
      end.to change { Devise::Mailer.deliveries.count }.by(0)
      expect(user.reload.invitation_sent_at).to be_nil
    end
  end

  context 'when the user has already received an invite' do
    let!(:user) do
      User.invite!(email: 'a-user-that-does-not-exist@example.com', skip_invitation: true).tap do |u|
        u.invitation_sent_at = Time.zone.now
      end
    end

    it 'does not send an invite' do
      expect do
        subject
      end.to change { Devise::Mailer.deliveries.count }.by(0)
    end
  end

  context 'when the user was created by but not yet received an invite' do
    let(:user) do
      User.invite!(email: 'a-user-that-does-not-exist@example.com', skip_invitation: true)
    end

    it 'sends an invite' do
      expect do
        subject
      end.to change { Devise::Mailer.deliveries.count }.by(1)
      expect(user.reload.invitation_sent_at).to be_present
    end
  end
end
