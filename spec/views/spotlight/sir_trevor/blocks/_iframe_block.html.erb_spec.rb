# frozen_string_literal: true

RSpec.describe 'spotlight/sir_trevor/blocks/_iframe_block.html.erb', type: :view do
  let(:partial) { 'spotlight/sir_trevor/blocks/iframe_block' }
  let(:block) do
    OpenStruct.new
  end

  it 'renders iframes' do
    block.code = "<iframe src='xyz'></iframe>"
    render partial:, locals: { iframe_block: block }
    expect(rendered).to have_css 'iframe[src="xyz"]'
  end

  it 'strips extra markup from the code' do
    block.code = '<a><b></b></a>'
    render partial:, locals: { iframe_block: block }
    expect(rendered).to be_blank
  end
end
