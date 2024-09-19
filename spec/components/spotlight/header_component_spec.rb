# frozen_string_literal: true

require "spec_helper"

RSpec.describe Spotlight::HeaderComponent, type: :component do


  

  context "when header is rendered" do
    let(:render) { render_inline(described_class.new(blacklight_config: CatalogController.blacklight_config)) }

    it 'has nav links' do
      expect(page).to have_selector '#user-util-collapse', text: 'links'
    end
  end
end
