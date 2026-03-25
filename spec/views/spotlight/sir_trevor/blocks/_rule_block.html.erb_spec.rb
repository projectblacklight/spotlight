# frozen_string_literal: true

RSpec.describe 'spotlight/sir_trevor/blocks/_rule_block.html.erb', type: :view do
  let(:partial) { 'spotlight/sir_trevor/blocks/rule_block' }

  it 'has an hr' do
    render partial: partial
    expect(rendered).to have_css 'hr'
  end
end
