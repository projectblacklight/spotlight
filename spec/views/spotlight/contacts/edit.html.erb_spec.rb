# frozen_string_literal: true

RSpec.describe 'spotlight/contacts/edit.html.erb' do
  let(:exhibit) { FactoryBot.create(:exhibit) }

  let(:contact) do
    Spotlight::Contact.new exhibit:
  end

  before do
    assign(:contact, contact)
    assign(:exhibit, exhibit)
    allow(view).to receive_messages(
      exhibit_contacts_path: '/exhibit/1/contacts',
      exhibit_about_pages_path: '/exhibit/admin/about',
      exhibit_alt_text_path: '/exhibit/1/alt-text',
      contact_images_path: '/contact_images',
      current_exhibit: exhibit
    )
    # Assumes that the second backend is the "Simple"
    I18n.backend.backends.second.store_translations(
      :en,
      spotlight: {
        contacts: {
          form: {
            new_field: {
              placeholder: 'place'
            },
            source: {
              remote: {
                help: 'Help!'
              }
            }
          }
        }
      }
    )
  end

  it 'has an IIIF crop' do
    render
    expect(rendered).to have_text 'Upload an image'
    expect(rendered).to have_css '.form-text', text: 'Help!'
    expect(rendered).to have_css '#contact_avatar_attributes_iiif_cropper'
  end
end
