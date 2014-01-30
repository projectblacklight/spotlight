require 'spec_helper'
require 'cancan/matchers'

describe Spotlight::Ability do
  let(:exhibit) {Spotlight::Exhibit.default}

  describe "a user with no roles" do
    subject { Ability.new(nil) }
    it { should_not be_able_to(:create, exhibit) }
  end

  describe "a user with admin role" do
    let(:user) { FactoryGirl.create(:exhibit_admin) }
    subject { Ability.new(user) }
    it { should be_able_to(:update, exhibit) }
  end

  describe "a user with curate role" do
    let(:user) { FactoryGirl.create(:exhibit_curator) }
    subject { Ability.new(user) }
    it { should be_able_to(:curate, exhibit) }
    it { should be_able_to(:create, Spotlight::Search) }
  end
end
