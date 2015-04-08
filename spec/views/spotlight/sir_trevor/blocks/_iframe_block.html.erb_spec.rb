require 'spec_helper'

describe 'spotlight/sir_trevor/blocks/_iframe_block.html.erb', type: :view do
  let(:p) { 'spotlight/sir_trevor/blocks/iframe_block.html.erb' }
  let(:block) do
    OpenStruct.new
  end

  it 'renders iframes' do
    block.code = "<iframe src='xyz'></iframe>"
    render partial: p, locals: { iframe_block: block }
    expect(rendered).to have_selector 'iframe[src="xyz"]'
  end

  it 'strips extra markup from the code' do
    block.code = '<a><b></b></a>'
    render partial: p, locals: { iframe_block: block }
    expect(rendered).to be_blank
  end
end
