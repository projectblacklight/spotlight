# frozen_string_literal: true

RSpec.describe Spotlight::ContactMailer do
  subject(:mail) { described_class.report_problem(contact_form) }

  let(:contact_form) do
    Spotlight::ContactForm.new(
      name: 'Jane',
      email: 'jane@example.com',
      current_exhibit: double(title: 'Exhibit title', contact_emails: []),
      request: double(remote_ip: '127.0.0.1', user_agent: 'rspec', uuid: 'abc')
    )
  end

  it "shows the reporter's email address" do
    expect(Nokogiri::HTML(mail.body.encoded).text).to include 'From: "Jane" <jane@example.com>'
  end
end
