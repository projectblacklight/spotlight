require 'spec_helper'

describe Spotlight::ContactEmail do
  it { should_not be_valid }

  describe "with a valid email set" do
    subject { Spotlight::ContactEmail.new(email: 'foo@example.com') }
    it { should be_valid }
  end
  describe "with an invalid email set" do
    subject { Spotlight::ContactEmail.new(email: '@-foo') }
    it "should not be valid" do
      expect(subject).to_not be_valid 
      expect(subject.errors[:email]).to eq ['is not valid']
    end
  end

end
