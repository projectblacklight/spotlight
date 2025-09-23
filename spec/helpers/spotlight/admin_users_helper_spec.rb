# frozen_string_literal: true

RSpec.describe Spotlight::AdminUsersHelper, type: :helper do
  describe '#sorted_exhibit_roles' do
    let(:user) { FactoryBot.create(:site_admin) }
    let!(:curator_role1) do
      FactoryBot.create(:role, user:, role: 'curator').tap do |r|
        r.resource.update(title: 'B Exhibit')
      end
    end
    let!(:curator_role2) do
      FactoryBot.create(:role, user:, role: 'curator').tap do |r|
        r.resource.update(title: 'A Exhibit')
      end
    end
    let!(:admin_role) { FactoryBot.create(:role, user:, role: 'admin') }

    it 'returns all exhibit roles for the user sorted by role and exhibit title' do
      expect(helper.sorted_exhibit_roles(user)).to eq([admin_role, curator_role2, curator_role1])
    end
  end

  describe '#user_badge_classes' do
    let(:site_admin) { FactoryBot.create(:site_admin) }
    let(:user) { FactoryBot.create(:user) }

    it 'returns expected classes for a superadmin user' do
      expect(helper.user_badge_classes(site_admin)).to eq('site-admin')
    end

    it 'returns expected classes for a user pending an invite' do
      allow(user).to receive(:invite_pending?).and_return(true)
      expect(helper.user_badge_classes(user)).to eq('invite-pending')
    end

    it 'returns expected classes for a superadmin user pending an invite' do
      allow(site_admin).to receive(:invite_pending?).and_return(true)
      expect(helper.user_badge_classes(site_admin)).to eq('site-admin invite-pending')
    end
  end
end
