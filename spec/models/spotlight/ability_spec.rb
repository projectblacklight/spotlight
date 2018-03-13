require 'cancan/matchers'

describe Spotlight::Ability, type: :model do
  before do
    allow_any_instance_of(Spotlight::Search).to receive(:set_default_featured_image)
  end
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:search) { FactoryBot.create(:published_search, exhibit: exhibit) }
  let(:unpublished_search) { FactoryBot.create(:search, exhibit: exhibit) }
  let(:page) { FactoryBot.create(:feature_page, exhibit: exhibit) }
  let(:language) { FactoryBot.create(:language, exhibit: exhibit) }
  let(:public_language) { FactoryBot.create(:language, exhibit: exhibit, public: true) }
  let(:translation) { FactoryBot.create(:translation, exhibit: exhibit) }
  subject { Ability.new(user) }

  describe 'a user with no roles' do
    let(:user) { nil }
    it { is_expected.not_to be_able_to(:create, exhibit) }
    it { is_expected.to be_able_to(:read, exhibit) }
    it { is_expected.to be_able_to(:read, page) }
    it { is_expected.not_to be_able_to(:create, Spotlight::Page.new(exhibit: exhibit)) }
    it { is_expected.to be_able_to(:read, search) }
    it { is_expected.to be_able_to(:read, public_language) }
    it { is_expected.not_to be_able_to(:read, language) }
    it { is_expected.not_to be_able_to(:read, unpublished_search) }
    it { is_expected.not_to be_able_to(:tag, exhibit) }
  end

  describe 'a superadmin' do
    let(:user) { FactoryBot.create(:site_admin) }

    it { is_expected.to be_able_to(:create, Spotlight::Exhibit) }
  end

  describe 'a user with admin role' do
    let(:user) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }
    let(:role) { FactoryBot.create(:role, resource: exhibit) }
    let(:blacklight_config) { exhibit.blacklight_configuration }

    it { is_expected.to be_able_to(:update, exhibit) }

    it { is_expected.to be_able_to(:index, role) }
    it { is_expected.to be_able_to(:destroy, role) }
    it { is_expected.to be_able_to(:update, role) }
    it { is_expected.to be_able_to(:create, Spotlight::Role) }
    it { is_expected.not_to be_able_to(:create, Spotlight::Exhibit) }
    it { is_expected.to be_able_to(:import, exhibit) }
    it { is_expected.to be_able_to(:process_import, exhibit) }
    it { is_expected.to be_able_to(:destroy, exhibit) }
    it { is_expected.to be_able_to(:manage, language) }
  end

  describe 'a user with curate role' do
    let(:user) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
    let(:contact) { FactoryBot.build_stubbed(:contact, exhibit: exhibit) }
    let(:blacklight_config) { exhibit.blacklight_configuration }

    it { is_expected.not_to be_able_to(:update, exhibit) }
    it { is_expected.to be_able_to(:curate, exhibit) }
    it { is_expected.to be_able_to(:read, exhibit) }

    it { is_expected.to be_able_to(:create, Spotlight::Search) }
    it { is_expected.to be_able_to(:update_all, Spotlight::Search) }
    it { is_expected.to be_able_to(:update, search) }
    it { is_expected.to be_able_to(:destroy, search) }

    it { is_expected.to be_able_to(:create, Spotlight::Page) }
    it { is_expected.to be_able_to(:update_all, Spotlight::Page) }
    it { is_expected.to be_able_to(:update, page) }
    it { is_expected.to be_able_to(:destroy, page) }

    it { is_expected.to be_able_to(:create, Translation) }
    it { is_expected.to be_able_to(:update_all, Translation) }
    it { is_expected.to be_able_to(:update, translation) }
    it { is_expected.to be_able_to(:destroy, translation) }

    it { is_expected.to be_able_to(:tag, exhibit) }

    it { is_expected.to be_able_to(:edit, contact) }
    it { is_expected.to be_able_to(:new, contact) }
    it { is_expected.to be_able_to(:create, contact) }
    it { is_expected.to be_able_to(:destroy, contact) }
    it { is_expected.not_to be_able_to(:manage, language) }
    it { is_expected.to be_able_to(:read, language) }
  end
end
