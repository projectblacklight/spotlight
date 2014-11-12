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
end