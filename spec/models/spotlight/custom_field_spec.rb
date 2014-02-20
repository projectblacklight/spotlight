require 'spec_helper'

describe Spotlight::CustomField do
  describe "#label" do
    subject { Spotlight::CustomField.new configuration: { "label" => "the configured label"} }
    its(:label) { should eq "the configured label"}
  end

  describe "#field" do
    it "should be auto-generated from the field label" do
      subject.configuration["label"] = "xyz"
      subject.exhibit = Spotlight::Exhibit.default
      subject.save

      expect(subject.field).to eq "exhibit_#{Spotlight::Exhibit.default.to_param}_xyz_tesim"
    end
  end
end
