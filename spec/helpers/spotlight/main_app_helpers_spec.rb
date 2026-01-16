# frozen_string_literal: true

RSpec.describe Spotlight::MainAppHelpers, type: :helper do
  describe '#show_contact_form?' do
    subject { helper }

    let(:exhibit) { FactoryBot.create(:exhibit) }
    let(:exhibit_with_contacts) { FactoryBot.create(:exhibit) }

    context 'with an exhibit with confirmed contacts' do
      before do
        exhibit_with_contacts.contact_emails.create(email: 'cabeer@stanford.edu').tap do |e|
          if e.respond_to? :confirm
            e.confirm
          else
            e.confirm!
          end
        end
        allow(helper).to receive_messages current_exhibit: exhibit_with_contacts
      end

      its(:show_contact_form?) { is_expected.to be_truthy }
    end

    context 'with an exhibit with only unconfirmed contacts' do
      before do
        exhibit_with_contacts.contact_emails.build email: 'cabeer@stanford.edu'
        allow(helper).to receive_messages current_exhibit: exhibit_with_contacts
      end

      its(:show_contact_form?) { is_expected.to be_falsey }
    end

    context 'with an exhibit without contacts' do
      before { allow(helper).to receive_messages current_exhibit: exhibit }

      its(:show_contact_form?) { is_expected.to be_falsey }
    end

    context 'outside the context of an exhibit' do
      before { allow(helper).to receive_messages current_exhibit: nil }

      its(:show_contact_form?) { is_expected.to be_falsey }
    end

    context 'with a default contact address' do
      before do
        allow(Spotlight::Engine.config).to receive_messages default_contact_email: 'root@localhost'
        allow(helper).to receive_messages current_exhibit: exhibit
      end

      its(:show_contact_form?) { is_expected.to be_truthy }
    end
  end
end
