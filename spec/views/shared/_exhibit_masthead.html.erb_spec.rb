require 'spec_helper'

module Spotlight
  describe "shared/_exhibit_masthead", :type => :view do
    let(:masthead) { Spotlight::Masthead.new }
    let(:search) { double(title: "Search Title", count: '12') }
    let(:current_exhibit) { double(title: "Some title", subtitle: "Subtitle", masthead: masthead) }
    let(:current_masthead) { double() }
    let(:current_exhibit_without_subtitle) { double(title: "Some title", subtitle: nil, masthead: masthead) }
    before do
      allow(view).to receive_messages(current_search_masthead?: nil)
      allow(view).to receive_messages(current_masthead: nil)
      allow(current_masthead).to receive_message_chain(:image, :cropped).and_return('/uploads/image.jpg')
    end

    describe 'title' do
      it "should display the title and subtitle" do
        allow(view).to receive_messages(current_exhibit: current_exhibit)
        render
        expect(rendered).to have_selector('.site-title', text: "Some title")
        expect(rendered).to have_selector('.site-title small', text: "Subtitle")
      end

      it "should display just the title" do
        allow(view).to receive_messages(current_exhibit: current_exhibit_without_subtitle)
        render
        expect(rendered).to have_selector('.site-title', text: "Some title")
        expect(rendered).to_not have_selector('.site-title small')
      end
    end

    describe 'masthead from exhibit' do
      before { allow(view).to receive_messages(current_exhibit: current_exhibit) }
      it 'should not include the background element when there is no masthead' do
        render
        expect(rendered).to_not have_selector('.background-container')
        expect(rendered).to_not have_selector('.background-container-gradient')
      end
      it 'should include the background image from the current exhibit' do
        allow(view).to receive_messages(current_masthead: current_masthead)
        render
        expect(rendered).to have_selector('.background-container[style="background-image: url(\'/uploads/image.jpg\')"]')
        expect(rendered).to have_selector('.background-container-gradient')
      end
    end

    describe 'masthead from search' do
      before do
        allow(view).to receive_messages(current_exhibit: current_exhibit)
        allow(view).to receive_messages(current_masthead: current_masthead)
        allow(view).to receive_messages(current_search_masthead?: true)
        assign(:search, search)
        render
      end
      it 'should include the background image from the current search' do
        expect(rendered).to have_selector('.background-container[style="background-image: url(\'/uploads/image.jpg\')"]')
        expect(rendered).to have_selector('.background-container-gradient')
      end
      it 'should not include the exhibit title when there is a current search masthead' do
        expect(rendered).to_not have_selector('.site-title', text: "Some title")
        expect(rendered).to_not have_selector('.site-title small', text: "Subtitle")
      end
      it 'should include the search title and count when there is a current search masthead' do
        expect(rendered).to have_selector('.site-title', text: "Search Title")
        expect(rendered).to have_selector('.site-title small', text: "12 items")
      end
    end

  end
end