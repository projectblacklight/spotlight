# frozen_string_literal: true

RSpec.describe 'Embedding exhibit items in an HTML page', :js, max_wait_time: 30 do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }
  let(:html_page) { FactoryBot.create(:feature_page, exhibit:, content_type: 'Html', content: '<p>Intro</p>') }

  before do
    login_as exhibit_curator
    visit spotlight.edit_exhibit_feature_page_path(exhibit, html_page)
    find('.ProseMirror p', text: 'Intro').click
    find('button[aria-label="Exhibit items"]').click
  end

  def add_item(id)
    fill_in_typeahead_field(type: 'embed', with: id)
    expect(page).to have_css('.html-editor-embed-item', text: id)
  end

  def embed_data
    node = Loofah.html5_fragment(html_page.reload.read_attribute(:content)).at_css('[data-spotlight-block]')
    [node['data-spotlight-block'], JSON.parse(node['data-spotlight-block-data'])]
  end

  it 'adds items, shows a preview, and renders them on the page' do
    within 'dialog[open]' do
      expect(page).to have_select 'Display as', selected: 'Item Row'
      select 'Item Grid', from: 'Display as'
      expect(page).to have_text 'Displays exhibit items in a multi-row grid.'
      expect(page).to have_no_field 'Primary caption'

      click_button 'Insert'
      expect(page).to have_css '.alert-danger', text: 'Add at least one item.'

      add_item 'dq287tq6352'
      add_item 'gk446cj2442'
      fill_in "Alternative text: L'AMERIQUE", with: 'A map of America'
      click_button 'Insert'
    end

    within '.html-editor-embed' do
      expect(page).to have_css '.html-editor-embed-name', text: 'Item Grid'
      expect(page).to have_css '.html-editor-embed-preview .item-grid-block .box', count: 2
    end

    click_button 'Save changes'
    expect(page).to have_text 'The feature page was successfully updated.'

    expect(page).to have_css '.html-page-content', text: 'Intro'
    expect(page).to have_css '.item-grid-block .box', count: 2
    expect(page).to have_css '.item-grid-block img[alt="A map of America"]'

    type, data = embed_data
    expect(type).to eq 'solr_documents_grid'
    expect(data['item'].values.pluck('id', 'weight', 'display')).to eq [%w[dq287tq6352 0 true], %w[gk446cj2442 1 true]]
  end

  it 'edits the widget type, items, and options' do
    within 'dialog[open]' do
      add_item 'dq287tq6352'
      add_item 'gk446cj2442'
      click_button 'Insert'
    end
    expect(page).to have_css '.html-editor-embed-preview .items-block .box', count: 2

    within('.html-editor-embed') { click_button 'Edit' }
    within 'dialog[open]' do
      expect(page).to have_css 'h2', text: 'Edit exhibit items'
      expect(page).to have_css '.html-editor-embed-item', count: 2
      select 'Item Carousel', from: 'Display as'
      select 'Title', from: 'Primary caption field'
      expect(page).to have_checked_field 'Primary caption'
      select 'Large', from: 'Maximum height'
      click_button "Move up: #{find_all('.html-editor-embed-item .fw-semibold').last.text}"
      uncheck "Show: L'AMERIQUE"
      click_button 'Save'
    end
    expect(page).to have_css '.html-editor-embed-name', text: 'Item Carousel'

    click_button 'Save changes'
    expect(page).to have_text 'The feature page was successfully updated.'

    type, data = embed_data
    expect(type).to eq 'solr_documents_carousel'
    expect(data).to include('show-primary-caption' => 'true', 'max-height' => 'large',
                            'primary-caption-field' => Spotlight::PageConfigurations::DOCUMENT_TITLE_KEY)
    expect(data['item'].values.pluck('id', 'display')).to eq [%w[gk446cj2442 true], %w[dq287tq6352 false]]
    expect(page).to have_css '.carousel-item', count: 1
  end

  it 'shows the search results on top of the dialog, rather than clipped by it' do
    within 'dialog[open]' do
      add_item 'dq287tq6352'
      add_item 'gk446cj2442'
      find('[data-embed-typeahead]').fill_in(with: 'a')
      expect(page).to have_css 'auto-complete[open] ul:popover-open [role="option"]'
    end

    # The bottom of the results is past the bottom of the dialog, and is what's actually shown there
    layout = page.evaluate_script(<<~JS)
      (() => {
        const popup = document.querySelector('dialog[open] auto-complete ul')
        const rect = popup.getBoundingClientRect()
        const dialog = document.querySelector('dialog[open]').getBoundingClientRect()
        const shown = document.elementFromPoint(rect.left + rect.width / 2, rect.bottom - 4)
        return { popupBottom: rect.bottom, dialogBottom: dialog.bottom, onTop: popup.contains(shown) }
      })()
    JS
    expect(layout['popupBottom']).to be > layout['dialogBottom']
    expect(layout['onTop']).to be true

    # Clicking elsewhere closes the results
    find('dialog[open] h2').click
    expect(page).to have_no_css 'ul:popover-open'
    within('dialog[open]') { click_button 'Cancel' }
    expect(page).to have_no_css 'dialog[open]'
  end

  it 'hides the "View larger" control in the preview, but not on the page' do
    within 'dialog[open]' do
      add_item 'dq287tq6352'
      check 'Offer "View larger" option'
      click_button 'Insert'
    end
    expect(page).to have_css '.html-editor-embed-preview .items-block .box'
    expect(page).to have_css '.html-editor-embed-preview .zpr-link', visible: :hidden

    click_button 'Save changes'
    expect(page).to have_text 'The feature page was successfully updated.'
    expect(page).to have_button(class: 'zpr-link')
  end

  it 'chooses an image from a multi-image item' do
    within 'dialog[open]' do
      add_item 'xd327cm9378'
      expect(page).to have_css('[data-panel-image-pagination]', text: /Image 1 of 2/)
      click_link 'Change'
      all('.thumbs-list li').last.click
      expect(page).to have_css('[data-panel-image-pagination]', text: /Image 2 of 2/)
      click_button 'Insert'
    end
    expect(page).to have_css '.html-editor-embed-preview .items-block .box'

    within('.html-editor-embed') { click_button 'Edit' }
    within 'dialog[open]' do
      expect(page).to have_css('[data-panel-image-pagination]', text: /Image 2 of 2/)
      click_button 'Cancel'
    end
  end

  it 'hides alt text fields for widgets without alt text, and removes embeds' do
    within 'dialog[open]' do
      add_item 'dq287tq6352'
      expect(page).to have_field "Alternative text: L'AMERIQUE"
      select 'Item Embed', from: 'Display as'
      expect(page).to have_no_field "Alternative text: L'AMERIQUE"
      click_button 'Insert'
    end
    expect(page).to have_css '.html-editor-embed-name', text: 'Item Embed'

    within('.html-editor-embed') { click_button 'Remove' }
    expect(page).to have_no_css '.html-editor-embed'
  end

  context 'when the cursor is inside other content' do
    let(:html_page) { FactoryBot.create(:feature_page, exhibit:, content_type: 'Html', content: '<blockquote><p>Intro</p></blockquote>') }

    it 'inserts the embed at the top level of the page' do
      within 'dialog[open]' do
        add_item 'dq287tq6352'
        click_button 'Insert'
      end
      expect(page).to have_css '.ProseMirror > .html-editor-embed'
      expect(page).to have_no_css 'blockquote .html-editor-embed'

      click_button 'Save changes'
      expect(page).to have_css '.items-block .box'
    end
  end
end
