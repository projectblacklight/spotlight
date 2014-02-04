require 'spec_helper'

describe Spotlight::Controller do
  class MockController < ActionController::Base
    include Spotlight::Controller
  end

  subject { MockController.new }

  describe "#current_exhibit" do
    it "should be the default exhibit" do
      subject.current_exhibit.should eq Spotlight::Exhibit.default
    end
  end
end