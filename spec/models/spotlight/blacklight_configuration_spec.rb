require 'spec_helper'

describe Spotlight::BlacklightConfiguration do
  subject { Spotlight::BlacklightConfiguration.new }
  let(:blacklight_config) { Blacklight::Configuration.new }

  describe "facet fields" do
    it "should have facet fields" do
      expect(subject.facet_fields).to eq []
      subject.facet_fields << 'title_facet' << 'author_facet'
      expect(subject.facet_fields).to eq ['title_facet', 'author_facet']
    end

    it "should filter blank values" do
      subject.facet_fields << ""
      subject.valid?
      expect(subject.facet_fields).to_not include ""
    end

    it "should filter the upstream blacklight config" do
      subject.facet_fields = ['a', 'c']
      subject.stub default_blacklight_config: blacklight_config
      blacklight_config.add_facet_field 'a'
      blacklight_config.add_facet_field 'b'
      blacklight_config.add_facet_field 'c'
      
      expect(subject.blacklight_config.facet_fields).to include('a', 'c')
      expect(subject.blacklight_config.facet_fields).to_not include('b')
      expect(subject.blacklight_config.facet_fields).to have(2).fields
    end
  end
end