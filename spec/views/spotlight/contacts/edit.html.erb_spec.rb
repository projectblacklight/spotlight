
describe 'spotlight/contacts/edit.html.erb' do
  let(:exhibit) { FactoryBot.create(:exhibit) }

  let(:contact) do
    Spotlight::Contact.new exhibit: exhibit
  end

  before do
    allow(view).to receive(:exhibit_contacts_path).and_return('/exhibit/1/contacts')
    allow(view).to receive(:exhibit_about_pages_path).and_return('/exhibit/admin/about')
    allow(view).to receive(:contact_images_path).and_return('/contact_images')
    assign(:contact, contact)
    assign(:exhibit, exhibit)
    allow(view).to receive(:current_exhibit).and_return(exhibit)
    # Assumes that the second backend is the "Simple"
    I18n.backend.backends.second.store_translations(
      :en,
      spotlight: {
        contacts: {
          form: {
            new_field: {
              placeholder: 'place'
            }
          }
        }
      }
    )
  end

  it 'has an IIIF crop' do
    render
    expect(rendered).to have_content 'Upload an image'
    expect(rendered).to have_selector '#contact_avatar_attributes_iiif_cropper'
  end
end
