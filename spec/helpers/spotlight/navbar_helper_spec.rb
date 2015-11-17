require 'spec_helper'

module Spotlight
  describe NavbarHelper, type: :helper do
    describe '#should_render_search_bar?' do
      before do
        allow(helper).to receive_messages(current_exhibit: nil)
        allow(helper).to receive_messages(exhibit_masthead?: true)
      end
      it 'returns false when there is no exhibit context' do
        expect(helper.should_render_spotlight_search_bar?).to be_falsey
      end
      it 'returns true if searchable' do
        allow(helper).to receive_messages(current_exhibit: double(searchable?: true))
        expect(helper.should_render_spotlight_search_bar?).to be_truthy
      end
      it 'returns false if currently under an "Exhibity" browse category' do
        allow(helper).to receive_messages(exhibit_masthead?: false)
        expect(helper.should_render_spotlight_search_bar?).to be_falsey
      end
    end
  end
end
