require 'spec_helper'

describe Spotlight::Contact do
  
  context "#show_in_sidebar" do
    it "should be an attribute" do
      subject.show_in_sidebar = false
      subject.save
      expect(subject.show_in_sidebar).to be_false
    end
    it "should be published by default" do
      subject.save
      expect(subject.show_in_sidebar).to be_true
    end
  end
end
