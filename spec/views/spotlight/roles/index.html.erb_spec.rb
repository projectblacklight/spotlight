# frozen_string_literal: true

describe 'spotlight/roles/index', type: :view do
  let(:user) { stub_model(Spotlight::Engine.user_class, email: 'jane@example.com') }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:admin_role) { FactoryBot.create(:role, role: 'admin', user: user, resource: exhibit) }
  let(:roles) { [admin_role] }

  before do
    assign(:exhibit, exhibit)
    allow(view).to receive(:current_exhibit).and_return(exhibit)
    allow(exhibit).to receive(:roles).and_return roles
  end

  it 'renders the index page form' do
    render

    action = spotlight.update_all_exhibit_roles_path(exhibit)
    assert_select "form[action='#{action}'][method='post']" do
      assert_select "tr[data-show-for='#{admin_role.id}']"
      assert_select "tr[data-edit-for='#{admin_role.id}']"
      assert_select 'td', /jane@example.com/
      assert_select 'td', 'Admin'
      assert_select "input[type='submit'][data-behavior='destroy-user'][data-target='#{admin_role.id}']"
      assert_select "input[type='hidden'][data-destroy-for='#{admin_role.id}']"
      assert_select "a[data-behavior='cancel-edit']"
      assert_select "input[type='submit'][value='Save changes']"
    end
  end
end
