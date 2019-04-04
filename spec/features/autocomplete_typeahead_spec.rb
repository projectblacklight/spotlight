# frozen_string_literal: true

describe 'Autocomplete typeahead', type: :feature, js: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:admin) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }

  before { login_as admin }

  describe 'IIIF Integration' do
    context 'for items that include a IIIF manifest' do
      it 'instantiates a cropper and persists all levels of the IIIF manifest' do
        visit spotlight.edit_exhibit_appearance_path(exhibit)
        click_link 'Exhibit masthead'

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

      it 'instantiates the multi-image selector when an multi-image item is chosen in the typeahead (and again on edit)' do
        allow(Spotlight::Engine.config).to receive(:exhibit_themes).and_return(['default'])

        visit spotlight.edit_exhibit_appearance_path(exhibit)

        check 'Show background image in masthead'

        fill_in_typeahead_field(with: 'xd327cm9378', type: 'featured-image')
        sleep 1 # HACK: that seems to mysteriously work.

        expect(page).to have_css('[data-panel-image-pagination]', text: /Image 1 of 2/, visible: true)

        # Open the multi-image selector and choose the last one
        click_link('Change')
        find('.thumbs-list li:last-child').click
        expect(page).to have_css('.leaflet-container', visible: true)

        click_button 'Save changes'

        expect(page).to have_content('The exhibit was successfully updated.')

        expect(page).to have_css('[data-panel-image-pagination]', text: /Image 2 of 2/, visible: true)
      end

      it 'removes the multi-image selector when a non multi-image item is selected' do
        visit spotlight.edit_exhibit_appearance_path(exhibit)
        click_link 'Exhibit masthead'

        fill_in_typeahead_field(with: 'xd327cm9378', type: 'featured-image')

        expect(page).to have_css('[data-panel-image-pagination]', text: /Image 1 of 2/, visible: true)

        fill_in_typeahead_field(with: 'gk446cj2442', type: 'featured-image')

        expect(page).not_to have_css('[data-panel-image-pagination]', text: /Image 1 of 2/)
      end
    end

    context 'for items that do not include a IIIF manifest' do
      before do
        allow(Spotlight::Engine.config).to receive(:iiif_manifest_field).and_return('not_a_real_field')
      end

      it 'provides an alert informing the user that they cannot crop from that item' do
        visit spotlight.edit_exhibit_appearance_path(exhibit)
        click_link 'Exhibit masthead'

        expect(page).not_to have_css('[data-behavior="non-iiif-alert"]', visible: true)

        fill_in_typeahead_field(with: 'gk446cj2442', type: 'featured-image')

        expect(page).to have_css('[data-behavior="non-iiif-alert"]', visible: true)
      end
    end
  end
end
