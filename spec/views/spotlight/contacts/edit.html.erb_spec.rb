require 'spec_helper'

describe 'spotlight/contacts/edit.html.erb' do
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  let(:contact) do
    Spotlight::Contact.new exhibit: exhibit
  end

  before do
    allow(view).to receive(:exhibit_contacts_path).and_return('/exhibit/1/contacts')
    allow(view).to receive(:exhibit_about_pages_path).and_return('/exhibit/admin/about')
    assign(:contact, contact)
    assign(:exhibit, exhibit)
    allow(view).to receive(:current_exhibit).and_return(exhibit)
  end

  it 'has a photo field' do
    render
    expect(rendered).to have_content 'Photo'
  end

  it 'has a cropbox' do
    render
    expect(rendered).to have_selector '#contact_avatar_cropbox'
  end
end
