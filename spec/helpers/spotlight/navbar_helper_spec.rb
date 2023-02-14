# frozen_string_literal: true

RSpec.describe Spotlight::NavbarHelper, type: :helper do
  describe '#should_render_spotlight_search_bar?' do
    before do
      allow(helper).to receive_messages(current_exhibit: nil)
      allow(helper).to receive_messages(exhibit_masthead?: true)
    end

    it 'returns false when there is no exhibit context' do
      expect(helper).not_to be_should_render_spotlight_search_bar
    end

    it 'returns true if searchable' do
      allow(helper).to receive_messages(current_exhibit: double(searchable?: true))
      expect(helper).to be_should_render_spotlight_search_bar
    end

    it 'returns false if currently under an "Exhibity" browse category' do
      allow(helper).to receive_messages(exhibit_masthead?: false)
      expect(helper).not_to be_should_render_spotlight_search_bar
    end
  end
end
