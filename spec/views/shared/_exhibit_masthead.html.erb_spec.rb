require 'spec_helper'

module Spotlight
  describe 'shared/_exhibit_masthead', type: :view do
    let(:masthead) { Spotlight::Masthead.new }
    let(:search) { double(title: 'Search Title', count: '12') }
    let(:current_exhibit) { double(title: 'Some title', subtitle: 'Subtitle', masthead: masthead) }
    let(:current_masthead) { double }
    let(:current_exhibit_without_subtitle) { double(title: 'Some title', subtitle: nil, masthead: masthead) }
    before do
      allow(view).to receive_messages(exhibit_masthead?: true)
      allow(view).to receive_messages(current_masthead: nil)
      allow(current_masthead).to receive_message_chain(:image, :cropped).and_return('/uploads/image.jpg')
    end

    describe 'title' do
      it 'displays the title and subtitle' do
        allow(view).to receive_messages(current_exhibit: current_exhibit)
        render
        expect(rendered).to have_selector('.site-title', text: 'Some title')
        expect(rendered).to have_selector('.site-title small', text: 'Subtitle')
      end

      it 'displays just the title' do
        allow(view).to receive_messages(current_exhibit: current_exhibit_without_subtitle)
        render
        expect(rendered).to have_selector('.site-title', text: 'Some title')
        expect(rendered).to_not have_selector('.site-title small')
      end
    end

    describe 'masthead from exhibit' do
      before { allow(view).to receive_messages(current_exhibit: current_exhibit) }
      it 'does not include the background element when there is no masthead' do
        render
        expect(rendered).to_not have_selector('.background-container')
        expect(rendered).to_not have_selector('.background-container-gradient')
      end
      it 'includes the background image from the current exhibit' do
        allow(view).to receive_messages(current_masthead: current_masthead)
        render
        expect(rendered).to have_selector('.background-container[style="background-image: url(\'/uploads/image.jpg\')"]')
        expect(rendered).to have_selector('.background-container-gradient')
      end
    end

    describe 'masthead from search' do
      let(:search_masthead) { 'CUSTOM MASTHEAD' }
      before do
        allow(view).to receive_messages(current_exhibit: current_exhibit)
        allow(view).to receive_messages(current_masthead: current_masthead)
        allow(view).to receive_messages(exhibit_masthead?: false)
        allow(view).to receive(:content_for?).with(:masthead).and_return(true)
        allow(view).to receive(:content_for).with(:masthead).and_return(search_masthead)
        render
      end
      it 'includes the background image from the current search' do
        expect(rendered).to have_selector('.background-container[style="background-image: url(\'/uploads/image.jpg\')"]')
        expect(rendered).to have_selector('.background-container-gradient')
      end
      it 'does not include the exhibit title when there is a current search masthead' do
        expect(rendered).to_not have_selector('.site-title', text: 'Some title')
        expect(rendered).to_not have_selector('.site-title small', text: 'Subtitle')
      end
      it 'includes the search title and count when there is a current search masthead' do
        expect(rendered).to have_content search_masthead
      end
    end
  end
end
