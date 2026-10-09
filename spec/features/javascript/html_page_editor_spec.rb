# frozen_string_literal: true

RSpec.describe 'Editing a page with the rich text (HTML) editor', :js do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }

  before do
    allow(Spotlight::Engine.config).to receive(:page_content_types).and_return(%w[SirTrevor Html])
    login_as exhibit_curator
  end

  it 'creates, edits, and displays an HTML page' do
    visit spotlight.exhibit_feature_pages_path(exhibit)
    add_new_via_button('Rich Text Page', alert: 'The feature page was created.', editor: 'Rich text editor')

    new_page = Spotlight::FeaturePage.find_by(title: 'Rich Text Page')
    expect(new_page.content_type).to eq 'Html'

    visit spotlight.edit_exhibit_feature_page_path(exhibit, new_page)
    editor = find('.html-editor-content .ProseMirror')
    editor.click
    find('[role=toolbar] button', text: 'H2').click
    editor.send_keys('My heading', :enter, 'Some ')
    find('button[aria-label="Bold"]').click
    editor.send_keys('bold text')
    expect(page).to have_css('button[aria-label="Bold"][aria-pressed="true"]')

    click_button 'Save changes'
    expect(page).to have_text 'The feature page was successfully updated.'

    expect(new_page.reload.read_attribute(:content)).to eq '<h2>My heading</h2><p>Some <strong>bold text</strong></p>'
    within '.html-page-content' do
      expect(page).to have_css 'h2', text: 'My heading'
      expect(page).to have_css 'strong', text: 'bold text'
    end
  end

  describe 'images' do
    let(:html_page) { FactoryBot.create(:feature_page, exhibit:, content_type: 'Html', content: '<p>Intro</p>') }
    let(:image_path) { File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')) }

    before do
      visit spotlight.edit_exhibit_feature_page_path(exhibit, html_page)
      find('.ProseMirror p', text: 'Intro').click
      find('button[aria-label="Image"]').click
    end

    it 'uploads an image with alt text, size, and position' do
      within 'dialog[open]' do
        attach_file 'Image file', image_path
        click_button 'Insert'
        expect(page).to have_css '.alert-danger', text: 'Enter alternative text'

        fill_in 'Alternative text', with: 'A small avatar'
        select 'Small', from: 'Size'
        select 'Right, with text wrapping', from: 'Position'
        click_button 'Insert'
      end
      expect(page).to have_no_css 'dialog[open]'
      expect(page).to have_css '.ProseMirror img[alt="A small avatar"][data-size="small"][data-align="right"]'

      click_button 'Save changes'
      expect(page).to have_text 'The feature page was successfully updated.'

      image = find('.html-page-content img')
      expect(image[:alt]).to eq 'A small avatar'
      expect(image[:src]).to include '/uploads/spotlight/attachment/file/'
      expect(image['data-size']).to eq 'small'
      expect(image['data-align']).to eq 'right'
      expect(Spotlight::Attachment.where(exhibit:).count).to eq 1
    end

    # NOTE: the test browser doesn't load images, so a decorative image (alt="") has only the editor's minimum size
    it 'edits an image to mark it as decorative' do
      within 'dialog[open]' do
        expect(page).to have_no_button 'Save'
        attach_file 'Image file', image_path
        fill_in 'Alternative text', with: 'An avatar'
        click_button 'Insert'
      end

      find('.ProseMirror img[alt="An avatar"]').double_click
      within 'dialog[open]' do
        expect(page).to have_no_field 'Image file'
        expect(page).to have_field 'Alternative text', with: 'An avatar'
        check "This image is decorative (it doesn't need alternative text)"
        expect(page).to have_field 'Alternative text', disabled: true
        select 'Full width', from: 'Size'
        click_button 'Save'
      end
      expect(page).to have_no_css 'dialog[open]'

      image = find('.ProseMirror img[data-decorative="true"][data-size="full"]')
      expect(image[:alt]).to eq ''

      image.double_click
      within 'dialog[open]' do
        expect(page).to have_checked_field "This image is decorative (it doesn't need alternative text)"
      end
    end

    %w[paste drop].each do |event_type|
      it "opens the image dialog for a #{event_type}d image file" do
        within('dialog[open]') { click_button 'Cancel' }
        page.execute_script(<<~JS, event_type)
          const png = atob('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=')
          const file = new File([Uint8Array.from(png, (c) => c.charCodeAt(0))], 'pixel.png', { type: 'image/png' })
          const data = new DataTransfer()
          data.items.add(file)
          const target = document.querySelector('.ProseMirror p')
          const rect = target.getBoundingClientRect()
          const event = arguments[0] === 'paste'
            ? new ClipboardEvent('paste', { clipboardData: data, bubbles: true, cancelable: true })
            : new DragEvent('drop', { dataTransfer: data, bubbles: true, cancelable: true, clientX: rect.left + 5, clientY: rect.top + 5 })
          target.dispatchEvent(event)
        JS

        within 'dialog[open]' do
          expect(page).to have_no_field 'Image file'
          fill_in 'Alternative text', with: "A #{event_type}d pixel"
          click_button 'Insert'
        end
        expect(page).to have_css ".ProseMirror img[alt='A #{event_type}d pixel'][src*='/uploads/spotlight/attachment/file/']"
      end
    end

    it 'can be cancelled' do
      within('dialog[open]') { click_button 'Cancel' }
      expect(page).to have_no_css 'dialog[open]'

      find('button[aria-label="Image"]').click
      find('dialog[open] input[type=text]').send_keys(:escape)
      expect(page).to have_no_css 'dialog[open]'
      expect(page).to have_no_css '.ProseMirror img'
    end
  end

  describe 'unsaved changes warning' do
    let(:html_page) { FactoryBot.create(:feature_page, exhibit:, content_type: 'Html', content: '<p>Existing <em>content</em></p>') }

    before do
      visit spotlight.exhibit_feature_page_path(exhibit, html_page)
      visit spotlight.edit_exhibit_feature_page_path(exhibit, html_page)
      find('.ProseMirror em', text: 'content') # wait for the editor to load
    end

    # The form observer warns on Turbo navigation (the Cancel link uses history.back(), which it doesn't observe)
    def navigate_away
      page.execute_script("Turbo.visit('#{spotlight.exhibit_dashboard_path(exhibit)}')")
    end

    it 'is not shown when nothing was edited' do
      expect { dismiss_confirm(wait: 1) { navigate_away } }.to raise_error(Capybara::ModalNotFound)
    end

    it 'is shown after the content is edited' do
      find('.ProseMirror').send_keys(' more')
      expect(dismiss_confirm { navigate_away }).to include 'unsaved changes'
    end
  end

  it 'still edits SirTrevor pages with SirTrevor' do
    sir_trevor_page = FactoryBot.create(:feature_page, exhibit:)
    visit spotlight.edit_exhibit_feature_page_path(exhibit, sir_trevor_page)
    expect(page).to have_css '.st-outer'
    expect(page).to have_no_css '.html-editor'
  end
end
