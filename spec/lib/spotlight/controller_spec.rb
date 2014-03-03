require 'spec_helper'

describe Spotlight::Controller do
  class MockController < ActionController::Base
    include Spotlight::Controller
  end

  subject { MockController.new }

  describe "#current_exhibit" do
    it "should be nil by default" do
      subject.current_exhibit.should be_nil
    end
  end
end