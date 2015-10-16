require 'spec_helper'

describe Spotlight::MainAppHelpers, type: :helper do
  describe '#show_contact_form?' do
    subject { helper }
    let(:exhibit) { FactoryGirl.create :exhibit }
    let(:exhibit_with_contacts) { FactoryGirl.create :exhibit }
    context 'with an exhibit with confirmed contacts' do
      before do
        exhibit_with_contacts.contact_emails.create(email: 'cabeer@stanford.edu').tap do |e|
          if e.respond_to? :confirm
            e.confirm
          else
            e.confirm!
          end
        end
      end
      before { allow(helper).to receive_messages current_exhibit: exhibit_with_contacts }
      its(:show_contact_form?) { should be_truthy }
    end

    context 'with an exhibit with only unconfirmed contacts' do
      before { exhibit_with_contacts.contact_emails.build email: 'cabeer@stanford.edu' }
      before { allow(helper).to receive_messages current_exhibit: exhibit_with_contacts }
      its(:show_contact_form?) { should be_falsey }
    end

    context 'with an exhibit without contacts' do
      before { allow(helper).to receive_messages current_exhibit: exhibit }
      its(:show_contact_form?) { should be_falsey }
    end

    context 'outside the context of an exhibit' do
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
    end
    context 'for sort fields' do
      let(:field) { Blacklight::Configuration::SortField.new enabled: true }
      it 'uses the enabled property for sort fields' do
        expect(helper.field_enabled?(field)).to eq true
      end
    end

    context 'for search fields' do
      let(:field) { Blacklight::Configuration::SearchField.new enabled: true }
      it 'uses the enabled property for search fields' do
        expect(helper.field_enabled?(field)).to eq true
      end
    end

    it 'returns the value of field#show if the action_name is "show"' do
      allow(field).to receive(:show).and_return(:value)
      allow(helper).to receive(:action_name).and_return('show')
      expect(helper.field_enabled?(field)).to eq :value
    end
    it 'returns the value of field#show if the action_name is "edit"' do
      allow(field).to receive(:show).and_return(:value)
      allow(helper).to receive(:action_name).and_return('edit')
      expect(helper.field_enabled?(field)).to eq :value
    end
    it 'returns the value of the original if condition' do
      allow(field).to receive(:upstream_if).and_return false
      expect(helper.field_enabled?(field)).to eq false
    end
  end

  describe '#enabled_in_spotlight_view_type_configuration?' do
    let(:controller) { OpenStruct.new }
    let(:view) { OpenStruct.new }
    before do
      controller.extend(Blacklight::Catalog)
      allow(helper).to receive(:controller).and_return(controller)
    end

    it 'respects the original if condition' do
      view.upstream_if = false
      expect(helper.enabled_in_spotlight_view_type_configuration?(view)).to eq false
    end

    it 'is true if there is no exhibit context' do
      allow(helper).to receive(:current_exhibit).and_return(nil)
      expect(helper.enabled_in_spotlight_view_type_configuration?(view)).to eq true
    end

    it "is true if we're in a page context" do
      allow(helper).to receive(:current_exhibit).and_return(nil)
      allow(controller).to receive(:is_a?).with(Spotlight::PagesController).and_return(true)
      expect(helper.enabled_in_spotlight_view_type_configuration?(view)).to eq true
    end
  end
end
