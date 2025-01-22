# frozen_string_literal: true

RSpec.describe 'spotlight/exhibits/edit', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }

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
      default_language?: true
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
end
