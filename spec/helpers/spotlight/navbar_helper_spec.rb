require 'spec_helper'

module Spotlight
  describe NavbarHelper, :type => :helper do
    describe '#should_render_search_bar?' do
      before do
        allow(helper).to receive_messages(current_exhibit: nil)
        allow(helper).to receive_messages(current_search_masthead?: nil)
      end
      it 'should return true when there is no exhibit context' do
        expect(helper.should_render_spotlight_search_bar?).to be_truthy
      end
      it 'should return true if searchable' do
        allow(helper).to receive_messages(current_exhibit: double(searchable?: true))
        expect(helper.should_render_spotlight_search_bar?).to be_truthy
      end
      it 'should return false if currently under an "Exhibity" browse category' do
        allow(helper).to receive_messages(current_search_masthead?: true)
        expect(helper.should_render_spotlight_search_bar?).to be_falsey
      end
    end
  end
end
