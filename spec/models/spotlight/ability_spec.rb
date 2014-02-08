require 'spec_helper'
require 'cancan/matchers'

describe Spotlight::Ability do
  let(:exhibit) {Spotlight::Exhibit.default}
  let(:search) {FactoryGirl.create(:search)}
  let(:page) {FactoryGirl.create(:feature_page)}

  describe "a user with no roles" do
    subject { Ability.new(nil) }
    it { should_not be_able_to(:create, exhibit) }
    it { should be_able_to(:read, exhibit) }
    it { should be_able_to(:read, page) }
    it { should_not be_able_to(:create, Spotlight::Page) }
    it { should be_able_to(:read, search) }
    it { should_not be_able_to(:edit, SolrDocument.new) }
    it { should_not be_able_to(:destroy, FactoryGirl.create(:tag)) }
  end

  describe "a user with admin role" do
    let(:user) { FactoryGirl.create(:exhibit_admin) }
    subject { Ability.new(user) }
    it { should be_able_to(:update, exhibit) }
  end

  describe "a user with curate role" do
    let(:user) { FactoryGirl.create(:exhibit_curator) }
    subject { Ability.new(user) }

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

    it { should be_able_to(:edit, SolrDocument.new) }

    it { should be_able_to(:index, ActsAsTaggableOn::Tag) }
    it { should be_able_to(:destroy, FactoryGirl.create(:tag)) }
  end
end
