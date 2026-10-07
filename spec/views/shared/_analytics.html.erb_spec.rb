# frozen_string_literal: true

RSpec.describe 'shared/_analytics', type: :view do
  it 'is empty without Google Analytics configured' do
    allow(Spotlight::Engine.config).to receive(:ga_measurement_id).and_return(nil)
    render
    expect(rendered).to be_empty
  end

  it 'renders the GA script tag if the GA measurement id is configured' do
    allow(Spotlight::Engine.config).to receive(:ga_measurement_id).and_return('G-XYZ1234567')
    render
    expect(rendered).to have_css 'script', visible: false
    expect(rendered).to have_text 'G-XYZ1234567'
  end
end
