require 'spec_helper'

describe Spotlight::Controller do
  class MockController < ActionController::Base
    include Spotlight::Controller
  end

  subject { MockController.new }

  before do
    allow(subject).to receive_messages(params: { action: 'show' })
  end

  describe '#current_exhibit' do
    it 'is nil by default' do
      expect(subject.current_exhibit).to be_nil
    end
  end

  describe '#exhibit_masthead?' do
    let(:masthead) { double('masthead', display?: true) }

    before do
      allow(subject).to receive_messages(current_exhibit: nil, current_masthead: nil)
    end

    it 'is false if there is no exhibit' do
      expect(subject.exhibit_masthead?).to be_falsey
    end

    it 'is false if there is no custom exhibit masthead' do
      allow(subject).to receive_messages(current_exhibit: double(masthead: nil), current_masthead: nil)
      expect(subject.exhibit_masthead?).to be_falsey
    end

    it 'is true if there is an exhibit masthead, but it is not set to display' do
      allow(subject).to receive_messages(current_exhibit: double(masthead: double(display?: false)))
      expect(subject.exhibit_masthead?).to be_falsey
    end

    it 'is true if there is an exhibit masthead' do
      allow(subject).to receive_messages(current_exhibit: double(masthead: double(display?: true)))
      expect(subject.exhibit_masthead?).to be_truthy
    end
  end

  describe '#current_masthead' do
    let(:search_masthead) { double('search-masthead', display?: true) }
    let(:no_display_search_masthead) { double('no-display-search-masthead', display?: false) }
    let(:exhibit_masthead) { double('exhibit-masthead', display?: true) }
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    let(:search) { FactoryGirl.create(:search) }

    it 'is nil by default' do
      expect(subject.current_masthead).to be_nil
    end

    it 'returns the exhibit masthead if available' do
      allow(exhibit).to receive_messages(masthead: exhibit_masthead)
      subject.instance_variable_set(:@exhibit, exhibit)
      expect(subject.current_masthead).to eq exhibit_masthead
    end

    it 'allows the masthead to be set' do
      subject.current_masthead = search_masthead
      expect(subject.current_masthead).to eq search_masthead
    end

    context 'with a resource masthead' do
      before do
        allow(subject).to receive(:resource_masthead?).and_return(true)
      end

      it 'checks if the current resource has a masthead' do
        pending
        expect(subject.current_masthead).to eq search_masthead
      end
    end
  end

  describe '#resource_masthead?' do
    it 'is false by default' do
      expect(subject.resource_masthead?).to eq false
    end
  end
end
