require 'spec_helper'
require 'cancan/matchers'

describe Spotlight::Ability do
  before do
    Spotlight::Search.any_instance.stub(:default_featured_image)
  end
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:search) {FactoryGirl.create(:published_search, exhibit: exhibit)}
  let(:unpublished_search) {FactoryGirl.create(:search, exhibit: exhibit)}
  let(:page) {FactoryGirl.create(:feature_page, exhibit: exhibit)}
  subject { Ability.new(user) }

  describe "a user with no roles" do
    let(:user) { nil }
    it { should_not be_able_to(:create, exhibit) }
    it { should be_able_to(:read, exhibit) }
    it { should be_able_to(:read, page) }
    it { should_not be_able_to(:create, Spotlight::Page.new(exhibit: exhibit)) }
    it { should be_able_to(:read, search) }
    it { should_not be_able_to(:read, unpublished_search) }
    it { should_not be_able_to(:tag, exhibit) }
  end

  describe "a superadmin" do
    let(:user) { FactoryGirl.create(:site_admin) }

    it { should be_able_to(:create,  Spotlight::Exhibit) }

  end

  describe "a user with admin role" do
    let(:user) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
    let(:role) { FactoryGirl.create(:role, exhibit: exhibit) }

    it { should be_able_to(:update, exhibit) }

    it { should be_able_to(:index,   role) }
    it { should be_able_to(:destroy, role) }
    it { should be_able_to(:update,  role) }
    it { should be_able_to(:create,  Spotlight::Role) }
    it { should_not be_able_to(:create,  Spotlight::Exhibit) }
    it { should be_able_to(:import,  exhibit) }
    it { should be_able_to(:process_import,  exhibit) }
    it { should be_able_to(:destroy,  exhibit) }

    let(:blacklight_config) { role.exhibit.blacklight_configuration }
    it { should be_able_to(:edit, Spotlight::Appearance.new(blacklight_config)) }
  end

  describe "a user with curate role" do
    let(:user) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }

    it { should_not be_able_to(:update, exhibit) }
    it { should be_able_to(:curate, exhibit) }
    it { should be_able_to(:read, exhibit) }

    it { should be_able_to(:create, Spotlight::Search) }
    it { should be_able_to(:update_all, Spotlight::Search) }
    it { should be_able_to(:update, search) }
    it { should be_able_to(:destroy, search) }

    it { should be_able_to(:create, Spotlight::Page) }
    it { should be_able_to(:update_all, Spotlight::Page) }
    it { should be_able_to(:update, page) }
    it { should be_able_to(:destroy, page) }

    it { should be_able_to(:tag, exhibit) }

    let(:contact) { FactoryGirl.create(:contact, exhibit: exhibit) }

    it { should be_able_to(:edit, contact) }
    it { should be_able_to(:new, contact) }
    it { should be_able_to(:create, contact) }
    it { should be_able_to(:destroy, contact) }

    let(:role) { FactoryGirl.create(:role, exhibit: user.roles.first.exhibit) }
    let(:blacklight_config) { role.exhibit.blacklight_configuration }
    it { should_not be_able_to(:edit, Spotlight::Appearance.new(blacklight_config)) }
  end
end
