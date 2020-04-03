# frozen_string_literal: true

describe 'spotlight/translations/_import.html.erb', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }

  before do
    allow(view).to receive(:can?).and_return(true)
    allow(view).to receive(:current_exhibit).and_return(exhibit)
  end

  it 'has a link to export the translation data' do
    render
    expect(rendered).to have_link 'Export translations', href: spotlight.exhibit_translations_path(exhibit_id: exhibit, format: 'yaml')
  end

  it 'has a form to import the translation data' do
    render
    expect(rendered).to have_selector "form[action='#{spotlight.import_exhibit_translations_path(exhibit_id: exhibit)}']"
    expect(rendered).to have_selector 'input[name="file"]'
  end
end
