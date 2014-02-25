require 'spec_helper'

describe Spotlight::CustomField do
  describe "#label" do
    subject { Spotlight::CustomField.new configuration: { "label" => "the configured label"}, field: 'foo_tesim' }
    describe "when the exhibit doesn't have a config" do
      its(:label) { should eq "the configured label"}
    end

    describe "when the exhibit has a config" do
      let(:exhibit) { FactoryGirl.create(:exhibit) }
      before { subject.exhibit = exhibit }
      describe "that overrides the label" do
        before do
          exhibit.blacklight_configuration.index_fields['foo_tesim'] = 
            Blacklight::Configuration::IndexField.new(label: "overridden")
        end
        its(:label) { should eq "overridden"}
      end
      describe "that doesn't override the label" do
        its(:label) { should eq "the configured label"}
      end
    end
  end

  describe "#label=" do
    subject { Spotlight::CustomField.new  field: 'foo_tesim' }
    describe "when the exhibit doesn't have a config" do
      before { subject.label = 'the configured label' }
      its(:configuration) { should eq({ 'label' => "the configured label" }) }
    end

    describe "when the exhibit has a config" do
      let(:exhibit) { FactoryGirl.create(:exhibit) }
      before { subject.exhibit = exhibit }
      describe "that overrides the label" do
        before do
          exhibit.blacklight_configuration.index_fields['foo_tesim'] = 
            Blacklight::Configuration::IndexField.new(label: "overridden")
          subject.label = 'edited'
        end
        it "should have updated the exhibit" do
          expect(subject.exhibit.blacklight_configuration.index_fields['foo_tesim']['label']).to eq 'edited'
        end
      end
    end
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
