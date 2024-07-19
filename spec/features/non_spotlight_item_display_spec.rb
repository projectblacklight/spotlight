# frozen_string_literal: true

RSpec.describe 'Non-spotlight item display', type: :feature do
  it 'is able to render without exhibit context' do
    visit solr_document_path('dq287tq6352')
    expect(page).to have_css 'h1', text: "L'AMERIQUE"
  end
end
