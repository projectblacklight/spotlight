# frozen_string_literal: true

describe Spotlight::ContactFormsController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:honeypot_field_name) { Spotlight::Engine.config.spambot_honeypot_email_field }

  before do
    request.env['HTTP_REFERER'] = 'http://example.com'
    exhibit.contact_emails_attributes = [{ 'email' => 'test@example.com' }, { 'email' => 'test2@example.com' }]
    exhibit.save!
    exhibit.contact_emails.first.tap do |e|
      if e.respond_to? :confirm
        e.confirm
      else
        e.confirm!
      end
    end
  end

  describe 'POST create' do
    it 'sends an email' do
      expect do
        post :create, params: { exhibit_id: exhibit.id, contact_form: { name: 'Joe Doe', email: 'jdoe@example.com', honeypot_field_name => '' } }
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
    it 'redirects back' do
      post :create, params: { exhibit_id: exhibit.id, contact_form: { name: 'Joe Doe', email: 'jdoe@example.com', honeypot_field_name => '' } }
      expect(response).to redirect_to 'http://example.com'
    end
    it 'sets a flash message' do
      post :create, params: { exhibit_id: exhibit.id, contact_form: { name: 'Joe Doe', email: 'jdoe@example.com', honeypot_field_name => '' } }
      expect(flash[:notice]).to eq 'Thanks. Your feedback has been sent.'
    end
  end
end
