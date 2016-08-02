
describe 'spotlight/contacts/edit.html.erb' do
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  let(:contact) do
    Spotlight::Contact.new exhibit: exhibit
  end

  before do
    allow(view).to receive(:exhibit_contacts_path).and_return('/exhibit/1/contacts')
    allow(view).to receive(:exhibit_about_pages_path).and_return('/exhibit/admin/about')
    allow(view).to receive(:featured_images_path).and_return('/featured_images')
    allow(view).to receive(:contact_crop).and_return('mock-uploader')
    assign(:contact, contact)
    assign(:exhibit, exhibit)
    allow(view).to receive(:current_exhibit).and_return(exhibit)
  end

  it 'has an IIIF crop' do
    render
    expect(rendered).to have_content 'mock-uploader'
  end
end
