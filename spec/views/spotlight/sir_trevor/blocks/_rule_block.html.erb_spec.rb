# frozen_string_literal: true

describe 'spotlight/sir_trevor/blocks/_rule_block', type: :view do
  let(:p) { 'spotlight/sir_trevor/blocks/rule_block' }

  it 'has an hr' do
    render partial: p
    expect(rendered).to have_selector 'hr'
  end
end
