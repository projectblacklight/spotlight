describe 'spotlight/exhibits/edit', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  before do
    assign(:exhibit, exhibit)
    allow(view).to receive_messages(
      current_exhibit: exhibit,
      can?: true,
      import_exhibit_path:  '/',
      get_exhibit_path:     '/',
      exhibit_filters_path: '/',
      exhibit_languages_path: '/',
      add_exhibit_language_dropdown_options: [],
      default_language?: true
    )
  end

  it 'renders the edit page form' do
    render

    expect(rendered).to have_selector "form[action=\"#{spotlight.exhibit_path(exhibit)}\"]"
    expect(rendered).to have_selector '.callout.callout-danger.row'
    expect(rendered).to have_content 'This action is irreversible'
    expect(rendered).to have_link 'Export data', href: spotlight.import_exhibit_path(exhibit)
    expect(rendered).to have_button 'Import data'
  end
end
