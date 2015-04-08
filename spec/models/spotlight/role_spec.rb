require 'spec_helper'

describe Spotlight::Role, type: :model do
  describe 'validations' do
    subject { described_class.new(args) }
    describe 'with nothing' do
      let(:args) { { user_key: '' } }
      it 'does not be valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq(role: ['is not included in the list'], user_key: ["can't be blank"])
      end
    end
    describe 'with user_key' do
      let(:user) { FactoryGirl.create(:user) }
      describe "that doesn't point at a user" do
        let(:args) { { role: 'curator', user_key: 'bob' } }
        it 'does not be valid' do
          expect(subject).not_to be_valid
          expect(subject.errors.messages).to eq(user_key: ['User must sign up first.'])
        end
      end
      describe 'that points at a user' do
        let(:args) { { role: 'curator', user_key: user.email } }
        it 'is valid' do
          expect(subject).to be_valid
          expect(subject.errors.messages).to be_empty
        end
      end
      describe 'that points at a user with an existing role' do
        before { described_class.create!(role: 'curator', user: user) }
        let(:args) { { role: 'curator', user_key: user.email } }
        it 'is valid' do
          expect(subject).not_to be_valid
          expect(subject.errors.messages).to eq(user_key: ['already a member of this exhibit'])
        end
      end
    end
  end
end
