require 'spec_helper'

module Spotlight
  describe 'shared/_analytics', type: :view do
    it 'is empty without Google Analytics configured' do
      render
      expect(rendered).to be_empty
    end

    it 'renders the GA script tag if the web property id is configured' do
      allow(Spotlight::Engine.config).to receive(:ga_web_property_id).and_return('XYZ-234')
      render
      expect(rendered).to have_selector 'script', visible: false
      expect(rendered).to have_content 'XYZ-234'
    end
  end
end
