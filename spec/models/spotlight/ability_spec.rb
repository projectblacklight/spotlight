require 'spec_helper'
require 'cancan/matchers'

describe Spotlight::Ability do
  describe "a user with no roles" do
    subject { Ability.new(nil) }
    let(:exhibit) {Spotlight::Exhibit.new(name: 'exhibit1')}
    it { should_not be_able_to(:create, exhibit) }
  end

  describe "a user with admin role" do
    let(:exhibit) {Spotlight::Exhibit.new(name: 'exhibit1')}
    let(:user) { FactoryGirl.create(:user) }
    before do
      exhibit.roles << Spotlight::Role.new(user: user)
      exhibit.save!
    end
    subject { Ability.new(user) }
    it { should be_able_to(:create, exhibit) }

  end
end
