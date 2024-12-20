# frozen_string_literal: true

RSpec.describe Spotlight::SelectImageComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(component).to_s)
  end

  let(:component) { described_class.new(1, 'st_block_abcd') }

  it 'has instructions for cropping the image' do
    expect(rendered).to have_content 'Adjust the image so that the rectangle'
  end

  it 'has the correct attributes for the cropper modal javascript' do
    css_attributes = 'div[data-behavior="iiif-cropper"][data-index-id="1"][data-cropper-key="select_image_st_block_abcd"]'
    expect(rendered).to have_css(css_attributes)
  end

  it 'has a save button' do
    expect(rendered).to have_css('input#save-cropping-selection[type="button"]')
  end

  it 'has a cancel button' do
    expect(rendered).to have_css('input[type="button"][value="Cancel"]')
  end
end
