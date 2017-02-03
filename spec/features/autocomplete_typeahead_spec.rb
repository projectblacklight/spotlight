describe 'Autocomplete typeahead', type: :feature, js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:admin) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }

  before { login_as admin }

  describe 'IIIF Integration' do
    context 'for items that include a IIIF manifest' do
      it 'instantiates a cropper and persists all levels of the IIIF manifest' do
        visit spotlight.edit_exhibit_appearance_path(exhibit)

        expect(page).not_to have_css('.leaflet-container')

        check 'Show background image in masthead'

        fill_in_typeahead_field(with: 'gk446cj2442', type: 'featured-image')

        expect(page).to have_css('.leaflet-container', visible: true)

        click_button 'Save changes'

        featured_image = Spotlight::FeaturedImage.last

        expect(featured_image.iiif_manifest_url).to eq 'https://purl.stanford.edu/gk446cj2442/iiif/manifest.json'
        expect(featured_image.iiif_canvas_id).to eq 'https://purl.stanford.edu/gk446cj2442/iiif/canvas/gk446cj2442_1'
        expect(featured_image.iiif_image_id).to eq 'https://purl.stanford.edu/gk446cj2442/iiif/annotation/gk446cj2442_1'
        expect(featured_image.iiif_tilesource).to eq 'https://stacks.stanford.edu/image/iiif/gk446cj2442%2Fgk446cj2442_05_0001/info.json'
      end
    end

    context 'for items that do not include a IIIF manifest' do
      before do
        allow(Spotlight::Engine.config).to receive(:iiif_manifest_field).and_return('not_a_real_field')
      end

      it 'provides an alert informing the user that they cannot crop from that item' do
        visit spotlight.edit_exhibit_appearance_path(exhibit)

        expect(page).not_to have_css('[data-behavior="non-iiif-alert"]', visible: true)

        fill_in_typeahead_field(with: 'gk446cj2442', type: 'featured-image')

        expect(page).to have_css('[data-behavior="non-iiif-alert"]', visible: true)
      end
    end
  end
end
