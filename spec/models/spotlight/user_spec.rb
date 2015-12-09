require 'spec_helper'

describe Spotlight::User do
  subject { Class.new }
  before { subject.extend described_class }

  describe '#invite_pending?' do
    it 'is false if the user was never invited in the first place' do
      expect(subject).to receive_messages(invited_to_sign_up?: false)
      expect(subject.invite_pending?).to be false
    end

    it 'is true if the user was invited but has not accepted' do
      expect(subject).to receive_messages(invited_to_sign_up?: true)
      expect(subject).to receive_messages(invitation_accepted?: false)
      expect(subject.invite_pending?).to be true
    end

    it 'is false if the user was invited and has accpeted the invite' do
      expect(subject).to receive_messages(invited_to_sign_up?: true)
      expect(subject).to receive_messages(invitation_accepted?: true)
      expect(subject.invite_pending?).to be false
    end
  end
end
