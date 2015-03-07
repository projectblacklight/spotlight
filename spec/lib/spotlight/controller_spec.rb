require 'spec_helper'

describe Spotlight::Controller do
  class MockController < ActionController::Base
    include Spotlight::Controller
  end

  subject { MockController.new }

  describe "#current_exhibit" do
    it "should be nil by default" do
      expect(subject.current_exhibit).to be_nil
    end
  end
  describe '#current_search_masthead?' do
    let(:masthead) { double('masthead', display?: true) }
    let(:no_display_masthead) { double('no-display-masthead', display?: false) }
    let(:search) { FactoryGirl.create(:search) }
    it 'should be false by default' do
      expect(subject.current_search_masthead?).to be_falsey
    end
    it "should return false if the current search's masthead is not set to display" do
      allow(search).to receive_messages(masthead: no_display_masthead)
      subject.instance_variable_set(:@search, search)
      expect(subject.current_search_masthead?).to be_falsey
    end
    it "should return true if the current search's masthead is set to display" do
      allow(search).to receive_messages(masthead: masthead)
      subject.instance_variable_set(:@search, search)
      expect(subject.current_search_masthead?).to be_truthy
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
    it 'should return the search masthead if available' do
      allow(search).to receive_messages(masthead: search_masthead)
      subject.instance_variable_set(:@search, search)
      expect(subject.current_masthead).to eq search_masthead
    end
    it 'should return the exhibit masthead if available' do
      allow(exhibit).to receive_messages(masthead: exhibit_masthead)
      subject.instance_variable_set(:@exhibit, exhibit)
      expect(subject.current_masthead).to eq exhibit_masthead
    end
    it 'should return the search masthead if both the exhibit and search masthead are available' do
      allow(search).to receive_messages(masthead: search_masthead)
      subject.instance_variable_set(:@search, search)
      allow(exhibit).to receive_messages(masthead: exhibit_masthead)
      subject.instance_variable_set(:@exhibit, exhibit)
      expect(subject.current_masthead).to eq search_masthead
    end
    it 'should return the exhibit masthead if the search masthead is set to not display' do
      allow(search).to receive_messages(masthead: no_display_search_masthead)
      subject.instance_variable_set(:@search, search)
      allow(exhibit).to receive_messages(masthead: exhibit_masthead)
      subject.instance_variable_set(:@exhibit, exhibit)
      expect(subject.current_masthead).to eq exhibit_masthead
    end
  end
end