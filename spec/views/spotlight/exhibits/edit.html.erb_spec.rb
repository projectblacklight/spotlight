# frozen_string_literal: true

RSpec.describe 'spotlight/exhibits/edit', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:default_language) { true }

  before do
    assign(:exhibit, exhibit)
    allow(view).to receive_messages(
      current_exhibit: exhibit,
      can?: true,
      import_exhibit_path: '/',
      get_exhibit_path: '/',
      exhibit_filters_path: '/',
      exhibit_languages_path: '/',
      exhibit_alt_text_path: '/',
      add_exhibit_language_dropdown_options: [],
      default_language?: default_language
    )
  end

  it 'renders the edit page form' do
    render

    expect(rendered).to have_selector "form[action=\"#{spotlight.exhibit_path(exhibit)}\"]"
    expect(rendered).to have_selector '.alert.alert-danger'
    expect(rendered).to have_content 'This action is irreversible'
    expect(rendered).to have_link 'Export data', href: spotlight.edit_exhibit_path(exhibit, anchor: 'export')
    expect(rendered).to have_button 'Import data'
  end

  describe 'when a locale other than the default is set' do
    let(:default_language) { false }

    before { render }

    it 'disables the input for translatable fields' do
      expect(rendered).to have_text 'This field is not editable in the current language'
      expect(rendered).to have_selector '#exhibit_title[disabled]'
      expect(rendered).to have_selector '#exhibit_subtitle[disabled]'
      expect(rendered).to have_selector '#exhibit_description[disabled]'
    end
  end
end
