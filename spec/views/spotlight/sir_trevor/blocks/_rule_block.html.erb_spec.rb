require 'spec_helper'

describe 'spotlight/sir_trevor/blocks/_rule_block.html.erb', type: :view do
  let(:p) { 'spotlight/sir_trevor/blocks/rule_block.html.erb' }

  it 'has an hr' do
    render partial: p
    expect(rendered).to have_selector 'hr'
  end
end
