require 'spec_helper'

describe Spotlight::CustomField, :type => :model do
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
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    it "should be auto-generated from the field label" do
      subject.configuration["label"] = "xyz"
      subject.exhibit = exhibit
      subject.save

      expect(subject.field).to eq "exhibit_#{exhibit.to_param}_xyz_tesim"
    end

    it "should use the solr field prefix" do
      allow(Spotlight::Engine.config.solr_fields).to receive(:prefix).and_return "prefix_"
      subject.configuration["label"] = "xyz"
      subject.exhibit = exhibit
      subject.save

      expect(subject.field).to eq "prefix_exhibit_#{exhibit.to_param}_xyz_tesim"
    end
  end

  describe '#configured_to_display?' do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    before do
      exhibit.blacklight_configuration.blacklight_config.view = {view_name: {}}
      subject.exhibit = exhibit
      subject.label = "Label"
      subject.field = 'foo_tesim'
    end
    it 'should be truthy when a view has been configured true' do
      exhibit.blacklight_configuration.blacklight_config.index_fields['foo_tesim'] =
        Blacklight::Configuration::IndexField.new(label: "Label", enabled: true, view_name: true)
      subject.save

      expect(subject).to be_configured_to_display
    end
    it 'should be truthey for show views when enabled' do
      exhibit.blacklight_configuration.blacklight_config.index_fields['foo_tesim'] =
        Blacklight::Configuration::IndexField.new(label: "Label", enabled: true, show: true)
      subject.save

      expect(subject).to be_configured_to_display
    end
    it 'should be falsey when a few has not been configured true' do
      exhibit.blacklight_configuration.blacklight_config.index_fields['foo_tesim'] =
        Blacklight::Configuration::IndexField.new(label: "Label", enabled: true, view_name: false)
      subject.save

      expect(subject).to_not be_configured_to_display
    end
    it 'should be falsey when the field is not enabled' do
      exhibit.blacklight_configuration.index_fields['foo_tesim'] =
        Blacklight::Configuration::IndexField.new(label: "Label", enabled: false, view_name: false)
      subject.save

      expect(subject).to_not be_configured_to_display
    end
  end

  describe "#field_name" do
    let(:exhibit) { double(to_param: "a") }

    before do
      subject.label = "xyz"
    end

    it "should end in the text suffix if it is a text field" do
      subject.field_type = "text"
      expect(subject.send(:field_name)).to end_with Spotlight::Engine.config.solr_fields.text_suffix
    end

    it "should end in a string suffix if it is a vocab field" do
      subject.field_type = "vocab"
      expect(subject.send(:field_name)).to end_with Spotlight::Engine.config.solr_fields.string_suffix
    end
  end

end
