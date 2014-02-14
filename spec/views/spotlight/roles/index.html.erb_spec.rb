require 'spec_helper'

module Spotlight
  describe "spotlight/roles/index" do
    let(:user) { stub_model(::User, email: 'jane@example.com') } 

    let(:exhibit) { Exhibit.default }
    let(:roles) { [FactoryGirl.create(:role, role: 'admin', user: user, exhibit: exhibit)] }

    before do
      assign(:exhibit, exhibit)
      view.stub(:current_exhibit).and_return(exhibit)
      exhibit.stub(:roles).and_return roles
      view.send(:extend, Spotlight::CrudLinkHelpers)
    end

    it "renders the index page form" do
      render

      assert_select "form[action=?][method=?]", spotlight.update_all_exhibit_roles_path(exhibit), "post" do
        assert_select "tr[data-show-for=?]", exhibit.id
        assert_select "tr[data-edit-for=?]", exhibit.id, 2
        assert_select "input[type='submit'][data-behavior='destroy-user'][data-target=?]", exhibit.id
        assert_select "input[type='hidden'][data-destroy-for=?]", exhibit.id
        assert_select "a[data-behavior='cancel-edit']"
        assert_select "input[type='submit'][value='Save changes']"
      end
    end
  end
end
