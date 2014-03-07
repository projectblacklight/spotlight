require 'spec_helper'

describe Spotlight::ContactEmail do
  before do
    Spotlight::Search.any_instance.stub(:default_featured_image)
  end
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  subject { Spotlight::ContactEmail.new(exhibit: exhibit) }

  it { should_not be_valid }

  describe "with an invalid email set" do
    before { subject.email = '@-foo' }
    it "should not be valid" do
      expect(subject).to_not be_valid 
      expect(subject.errors[:email]).to eq ['is not valid']
    end
  end

  describe "with a valid email set" do
    before { subject.email = 'foo@example.com' }
    it { should be_valid }

    describe "when saved" do
      it "should send a confirmation" do
        subject.should_receive(:send_devise_notification)
        subject.save 
      end
    end
    describe "#send_devise_notification" do
      it "should send stuff" do
        expect {
          subject.send(:send_devise_notification, :confirmation_instructions, "Q7PEPdLVxymsQL2_s_Rg", {})
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end

end
