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
