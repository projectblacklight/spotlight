describe 'Autocomplete typeahead', type: :feature, js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:admin) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }

  before { login_as admin }

  describe 'IIIF Integration' do
    context 'for items that include a IIIF manifest' do
      it 'instantiates a cropper' do
        visit spotlight.edit_exhibit_appearance_path(exhibit)

        expect(page).not_to have_css('.leaflet-container')

        fill_in_typeahead_field(with: 'gk446cj2442', type: 'masthead')

        expect(page).to have_css('.leaflet-container', visible: true)
      end
    end

    context 'for items that do not include a IIIF manifest' do
      before do
        Spotlight::Engine.config.iiif_manifest_field = 'not_a_real_field'
      end

      it 'provides an alert informing the user that they cannot crop from that item' do
        visit spotlight.edit_exhibit_appearance_path(exhibit)

        expect(page).not_to have_css('[data-behavior="non-iiif-alert"]', visible: true)

        fill_in_typeahead_field(with: 'gk446cj2442', type: 'masthead')

        expect(page).to have_css('[data-behavior="non-iiif-alert"]', visible: true)
      end
    end
  end
end
