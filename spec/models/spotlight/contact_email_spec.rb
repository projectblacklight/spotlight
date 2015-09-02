require 'spec_helper'

describe Spotlight::ContactEmail, type: :model do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  subject { described_class.new(exhibit: exhibit) }

  it { is_expected.not_to be_valid }

  describe 'with an invalid email set' do
    before { subject.email = '@-foo' }
    it 'does not be valid' do
      expect(subject).to_not be_valid
      expect(subject.errors[:email]).to eq ['is not valid']
    end
  end

  describe 'with a valid email set' do
    before { subject.email = 'foo@example.com' }
    it { is_expected.to be_valid }

    describe 'when saved' do
      it 'sends a confirmation' do
        expect(subject).to receive(:send_devise_notification)
        subject.save
      end
    end
    describe '#send_devise_notification' do
      it 'sends stuff' do
        expect do
          subject.send(:send_devise_notification, :confirmation_instructions, 'Q7PEPdLVxymsQL2_s_Rg', {})
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end

  describe '.confirmed' do
    it 'scopes contacts to only confirmed contacts' do
      a = exhibit.contact_emails.create(email: 'a@example.com')
      if a.respond_to? :confirm
        a.confirm
      else
        a.confirm!
      end

      b = exhibit.contact_emails.create(email: 'b@example.com')

      expect(described_class.confirmed.to_a).to include a
      expect(described_class.confirmed.to_a).to_not include b
    end
  end
end
