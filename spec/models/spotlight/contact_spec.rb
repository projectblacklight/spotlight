require 'spec_helper'

describe Spotlight::Contact, :type => :model do
  
  context "#show_in_sidebar" do
    it "should be an attribute" do
      subject.show_in_sidebar = false
      subject.save
      expect(subject.show_in_sidebar).to be_falsey
    end
    it "should be published by default" do
      subject.save
      expect(subject.show_in_sidebar).to be_truthy
    end
  end
end
