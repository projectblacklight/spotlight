# frozen_string_literal: true

RSpec.describe Spotlight::ContactForm do
  subject { described_class.new(name: 'Root', email: 'user@example.com') }

  let(:exhibit) { FactoryBot.build_stubbed(:exhibit) }
  let(:honeypot_field_name) { Spotlight::Engine.config.spambot_honeypot_email_field }

  describe 'the email subject' do
    it 'has a subject' do
      expect(subject.headers[:subject]).to eq 'Blacklight exhibit feedback'
    end

    context 'with a current exhibit' do
      before do
        subject.current_exhibit = exhibit
        exhibit.title = 'My exhibit'
      end

      it 'uses the site title in the email' do
        expect(subject.headers[:subject]).to eq 'My exhibit exhibit feedback'
      end
    end

    context 'with a site title' do
      before do
        Spotlight::Site.instance.update(title: 'Exhibits')
      end

      it 'uses the site title in the email' do
        expect(subject.headers[:subject]).to eq 'Exhibits exhibit feedback'
      end
    end
  end

  context 'with a site-wide contact email' do
    before { allow(Spotlight::Engine.config).to receive_messages default_contact_email: 'root@localhost' }

    it 'sends the email to the configured contact' do
      expect(subject.headers[:to]).to eq Spotlight::Engine.config.default_contact_email
    end

    context 'with exhibit-specific contacts' do
      before do
        subject.current_exhibit = exhibit
        exhibit.contact_emails.create(email: 'curator@example.com', confirmed_at: Time.zone.now)
      end

      it 'appends exhibit-specific contacts as cc recipients' do
        expect(subject.headers[:cc]).to eq 'curator@example.com'
      end
    end
  end

  context 'with exhibit-specific contacts' do
    before do
      subject.current_exhibit = exhibit
      exhibit.contact_emails.create(email: 'curator@example.com', confirmed_at: Time.zone.now)
      exhibit.contact_emails.create(email: 'addl_curator@example.com', confirmed_at: Time.zone.now)
    end

    it 'sends the email to the first contact' do
      expect(subject.headers[:to]).to eq 'curator@example.com'
    end

    it 'appends exhibit-specific contacts as cc recipients' do
      expect(subject.headers[:cc]).to eq 'curator@example.com, addl_curator@example.com'
    end
  end

  context 'when validating feedback submission fields' do
    it 'allows submissions that set a valid email address' do
      subject.email = 'user@legitimatebusinesspersonssocialclub.biz'
      subject.send("#{honeypot_field_name}=", '')
      expect(subject).to be_valid
    end

    it 'rejects submissions that set an invalid email address' do
      subject.email = 'user'
      subject.send("#{honeypot_field_name}=", '')
      expect(subject).not_to be_valid
    end

    it 'allows submissions that leave the spammer honeypot field blank' do
      subject.send("#{honeypot_field_name}=", '')
      expect(subject).to be_valid
    end

    it 'rejects submissions that set the spammer honeypot field' do
      subject.send("#{honeypot_field_name}=", 'spam@spam.com')
      expect(subject).not_to be_valid
    end
  end
end
