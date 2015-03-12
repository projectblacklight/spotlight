require 'spec_helper'

describe Spotlight::Controller do
  class MockController < ActionController::Base
    include Spotlight::Controller
  end

  subject { MockController.new }

  before do
    allow(subject).to receive_messages(params: {action: 'show'})
  end

  describe "#current_exhibit" do
    it "should be nil by default" do
      expect(subject.current_exhibit).to be_nil
    end
  end

  describe '#exhibit_masthead?' do
    let(:masthead) { double('masthead', display?: true) }

    before do
      allow(subject).to receive_messages(current_exhibit: nil, current_masthead: nil)
    end

    it "should be true if there is no exhibit" do
      expect(subject.exhibit_masthead?).to eq true
    end

    it "should be true if there is no custom exhibit masthead" do
      allow(subject).to receive_messages(current_exhibit: double, current_masthead: nil)
      expect(subject.exhibit_masthead?).to eq true
    end

    it "should be false if the current masthead is not the exhibit masthead" do
      allow(subject).to receive_messages(current_exhibit: double(masthead: double), current_masthead: masthead)
      expect(subject.exhibit_masthead?).to eq false
    end
  end
  describe '#current_masthead' do
    let(:search_masthead) { double('search-masthead', display?: true) }
    let(:no_display_search_masthead) { double('no-display-search-masthead', display?: false) }
    let(:exhibit_masthead) { double('exhibit-masthead', display?: true) }
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    let(:search) { FactoryGirl.create(:search) }
    it 'should be nil by default' do
      expect(subject.current_masthead).to be_nil
    end
    it 'should return the exhibit masthead if available' do
      allow(exhibit).to receive_messages(masthead: exhibit_masthead)
      subject.instance_variable_set(:@exhibit, exhibit)
      expect(subject.current_masthead).to eq exhibit_masthead
    end
    it 'should allow the masthead to be set' do
      subject.current_masthead = search_masthead
      expect(subject.current_masthead).to eq search_masthead
    end
  end
end