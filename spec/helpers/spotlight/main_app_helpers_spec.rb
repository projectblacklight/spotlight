require 'spec_helper'

describe Spotlight::MainAppHelpers, :type => :helper do
  
  describe "#show_contact_form?" do
    subject { helper }
    let(:exhibit) { FactoryGirl.create :exhibit }
    let(:exhibit_with_contacts) { FactoryGirl.create :exhibit }
    context "with an exhibit with confirmed contacts" do
      before { exhibit_with_contacts.contact_emails.create(email: 'cabeer@stanford.edu').confirm! }
      before { allow(helper).to receive_messages current_exhibit: exhibit_with_contacts }
      its(:show_contact_form?) { should be_truthy }
    end

    context "with an exhibit with only unconfirmed contacts" do
      before { exhibit_with_contacts.contact_emails.build email: 'cabeer@stanford.edu' }
      before { allow(helper).to receive_messages current_exhibit: exhibit_with_contacts }
      its(:show_contact_form?) { should be_falsey }
    end
    
    
    context "with an exhibit without contacts" do
      before { allow(helper).to receive_messages current_exhibit: exhibit }
      its(:show_contact_form?) { should be_falsey }
    end
    
    context "outside the context of an exhibit" do
      before { allow(helper).to receive_messages current_exhibit: nil }
      its(:show_contact_form?) { should be_falsey }
    end
  end

  describe '#field_enabled?' do
    let(:field) { FactoryGirl.create(:custom_field) }
    let(:controller) { OpenStruct.new }
    before do
      controller.extend(Blacklight::Catalog)
      allow(helper).to receive(:controller).and_return(controller)
      allow(helper).to receive(:document_index_view_type).and_return(nil)
      allow(field).to receive(:enabled).and_return(true)
      allow(field).to receive(:show).and_return(:value)
    end
    it 'should return the value of field#show if the action_name is "show"' do
      allow(helper).to receive(:action_name).and_return("show")
      expect(helper.field_enabled?(field)).to eq :value
    end
    it 'should return the value of field#show if the action_name is "edit"' do
      allow(helper).to receive(:action_name).and_return("edit")
      expect(helper.field_enabled?(field)).to eq :value
    end
  end

  describe "save_search rendering" do
    let(:current_exhibit) { FactoryGirl.create(:exhibit) }
    before { allow(helper).to receive_messages(current_exhibit: current_exhibit) }
    describe "render_save_this_search?" do
      it "should return false if we are on the items admin screen" do
        allow(helper).to receive(:"can?").with(:curate, current_exhibit).and_return(true)
        allow(helper).to receive(:params).and_return({controller: "spotlight_catalog_controller", action: "admin"})
        expect(helper.render_save_this_search?).to be_falsey
      end
      it "should return true if we are on the items admin screen" do
        allow(helper).to receive(:"can?").with(:curate, current_exhibit).and_return(true)
        allow(helper).to receive(:params).and_return({controller: "catalog_controller", action: "index"})
        expect(helper.render_save_this_search?).to be_truthy
      end
      it "should return false if a user cannot curate the object" do
        allow(helper).to receive(:"can?").with(:curate, current_exhibit).and_return(false)
        expect(helper.render_save_this_search?).to be_falsey
      end
    end
    describe "render_save_search" do
      it "should do render the save_search partial if render_save_this_search? return true" do
        allow(helper).to receive(:"render_save_this_search?").and_return true
        allow(helper).to receive(:render).with('save_search').and_return "saved-search-partial"
        expect(helper.render_save_search).to eq "saved-search-partial"
      end
      it "should do nothing if render_save_this_search? return false" do
        allow(helper).to receive(:"render_save_this_search?").and_return false
        expect(helper.render_save_search).to be_blank
      end
    end
  end

end
