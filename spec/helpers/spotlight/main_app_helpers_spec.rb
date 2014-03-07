require 'spec_helper'

describe Spotlight::MainAppHelpers do
  
  describe "#show_contact_form?" do
    subject { helper }
    let(:exhibit) { FactoryGirl.create :exhibit }
    let(:exhibit_with_contacts) { FactoryGirl.create :exhibit }
    context "with an exhibit with confirmed contacts" do
      before { exhibit_with_contacts.contact_emails.create(email: 'cabeer@stanford.edu').confirm! }
      before { helper.stub current_exhibit: exhibit_with_contacts }
      its(:show_contact_form?) { should be_true }
    end

    context "with an exhibit with only unconfirmed contacts" do
      before { exhibit_with_contacts.contact_emails.build email: 'cabeer@stanford.edu' }
      before { helper.stub current_exhibit: exhibit_with_contacts }
      its(:show_contact_form?) { should be_false }
    end
    
    
    context "with an exhibit without contacts" do
      before { helper.stub current_exhibit: exhibit }
      its(:show_contact_form?) { should be_false }
    end
    
    context "outside the context of an exhibit" do
      before { helper.stub current_exhibit: nil }
      its(:show_contact_form?) { should be_false }
    end
  end
end
