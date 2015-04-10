require 'spec_helper'

describe 'Confirming an email', type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:contact_email) { Spotlight::ContactEmail.create!(email: 'justin@example.com', exhibit: exhibit) }
  let(:raw_token) { contact_email.instance_variable_get(:@raw_confirmation_token) }

  it 'resends confirmation instructions' do
    visit spotlight.new_contact_email_confirmation_url(confirmation_token: contact_email.confirmation_token)
    expect(page).to have_content('Resend confirmation instructions')
    within '#new_contact_email' do
      fill_in 'Email', with: contact_email.email
      click_button 'Resend confirmation instructions'
    end
  end

  it 'confirms email' do
    visit spotlight.contact_email_confirmation_url(confirmation_token: raw_token)
    expect(page).to have_content('successfully confirmed')
  end
end
