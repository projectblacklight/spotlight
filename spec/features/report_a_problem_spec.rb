# frozen_string_literal: true

describe 'Report a Problem', type: :feature do
  let!(:exhibit) { FactoryBot.create(:exhibit) }
  let(:honeypot_field_name) { Spotlight::Engine.config.spambot_honeypot_email_field }

  it 'does not have a header link' do
    visit root_path
    expect(page).to_not have_content 'Feedback'
  end

  describe 'when emails are setup' do
    before do
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

    it 'allows the link to be opened w/o javascript (or in a new tab/window)' do
      visit spotlight.exhibit_solr_document_path(exhibit, id: 'dq287tq6352')

      click_on 'Feedback'

      expect(page).to have_css('h2', text: 'Contact Us', visible: true)
    end

    it 'accepts a problem report', js: true do
      visit spotlight.exhibit_solr_document_path(exhibit, id: 'dq287tq6352')
      click_on 'Feedback'
      expect(find('#contact_form_current_url', visible: false).value).to end_with spotlight.exhibit_solr_document_path(exhibit, id: 'dq287tq6352')
      fill_in 'Name', with: 'Some Body'
      fill_in 'Email', with: 'test@example.com'
      fill_in 'Message', with: 'This is my problem report'

      expect do
        click_on 'Send'
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'rejects a spammy looking problem report', js: true do
      visit spotlight.exhibit_solr_document_path(exhibit, id: 'dq287tq6352')
      click_on 'Feedback'
      expect(find('#contact_form_current_url', visible: false).value).to end_with spotlight.exhibit_solr_document_path(exhibit, id: 'dq287tq6352')
      fill_in 'Name', with: 'Some Body'
      fill_in 'Email', with: 'test@example.com'
      page.evaluate_script("$('#contact_form_#{honeypot_field_name}').val('possible_spam@spam.com')")
      fill_in 'Message', with: 'This is my problem report'

      expect do
        click_on 'Send'
      end.not_to change { ActionMailer::Base.deliveries.count }
    end
  end
end
