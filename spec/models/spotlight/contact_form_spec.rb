require 'spec_helper'

describe Spotlight::ContactForm do
  subject { described_class.new(name: 'Root', email: 'user@example.com').tap { |c| c.current_exhibit = exhibit } }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  context 'with a site-wide contact email' do
    before { allow(Spotlight::Engine.config).to receive_messages default_contact_email: 'root@localhost' }

    it 'sends the email to the configured contact' do
      expect(subject.headers[:to]).to eq Spotlight::Engine.config.default_contact_email
    end

    context 'with exhibit-specific contacts' do
      before { exhibit.contact_emails.create(email: 'curator@example.com', confirmed_at: Time.zone.now) }

      it 'appends exhibit-specific contacts as cc recipients' do
        expect(subject.headers[:cc]).to eq 'curator@example.com'
      end
    end
  end

  context 'with exhibit-specific contacts' do
    before { exhibit.contact_emails.create(email: 'curator@example.com', confirmed_at: Time.zone.now) }
    before { exhibit.contact_emails.create(email: 'addl_curator@example.com', confirmed_at: Time.zone.now) }

    it 'sends the email to the first contact' do
      expect(subject.headers[:to]).to eq 'curator@example.com'
    end

    it 'appends exhibit-specific contacts as cc recipients' do
      expect(subject.headers[:cc]).to eq 'curator@example.com, addl_curator@example.com'
    end
  end
end
