require 'spec_helper'

describe Spotlight::ContactFormsController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }
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
    it 'redirects back' do
      post :create, exhibit_id: exhibit.id, contact_form: { name: 'Joe Doe', email: 'jdoe@example.com' }
      expect(response).to redirect_to :back
    end
    it 'sets a flash message' do
      post :create, exhibit_id: exhibit.id, contact_form: { name: 'Joe Doe', email: 'jdoe@example.com' }
      expect(flash[:notice]).to eq 'Thanks. Your feedback has been sent.'
    end
  end
end
