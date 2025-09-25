# frozen_string_literal: true

RSpec.describe Spotlight::AdminUsers::ExhibitRolesComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new(user:)).to_s)
  end

  let(:user) { FactoryBot.create(:user) }

  context 'when user has exhibit roles' do
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

    it 'displays exhibit roles for the user sorted by role and exhibit title' do
      expect(rendered).to have_css('details ul',
                                   text: "#{admin_role.resource.title} (Admin) A Exhibit (Curator) B Exhibit (Curator)",
                                   normalize_ws: true,
                                   visible: false)
    end

    it 'links to remove all exhibit roles for the user' do
      expect(rendered).to have_link 'Remove all exhibit roles', href: spotlight.remove_exhibit_roles_admin_user_path(user)
    end
  end

  context 'when user has no exhibit roles' do
    it 'is blank' do
      expect(rendered.native.inner_html).to eq('')
    end
  end
end
