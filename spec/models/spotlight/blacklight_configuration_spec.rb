require 'spec_helper'

describe Spotlight::BlacklightConfiguration do
  subject { Spotlight::BlacklightConfiguration.new }
  let(:blacklight_config) { Blacklight::Configuration.new }

  before :each do
    subject.stub default_blacklight_config: blacklight_config
    subject.exhibit = Spotlight::Exhibit.default
  end

  describe "facet fields" do
    it "should have facet fields" do
      expect(subject.facet_fields).to be_empty
      subject.facet_fields["title_facet"] = {}
      subject.facet_fields["author_facet"] = {}
      expect(subject.facet_fields.keys).to eq ['title_facet', 'author_facet']
    end

    it "should filter blank values" do
      subject.facet_fields["title_facet"] = { something: "" }
      subject.valid?
      expect(subject.facet_fields["title_facet"].keys).to_not include :something
    end

    it "should filter the upstream blacklight config" do
      subject.facet_fields['a'] = { enabled: true }
      subject.facet_fields['b'] = { enabled: false }
      subject.facet_fields['d'] = { enabled: true }

      blacklight_config.add_facet_field 'a'
      blacklight_config.add_facet_field 'b'
      blacklight_config.add_facet_field 'c'

      expect(subject.blacklight_config.facet_fields).to include('a')
      expect(subject.blacklight_config.facet_fields).to_not include('b')
      expect(subject.blacklight_config.facet_fields).to have(1).fields
    end

    it "should order the fields by weight" do

      subject.facet_fields['a'] = { enabled: true, weight: 3 }
      subject.facet_fields['b'] = { enabled: true, weight: 5 }
      subject.facet_fields['c'] = { enabled: true, weight: 1 }

      blacklight_config.add_facet_field 'a'
      blacklight_config.add_facet_field 'b'
      blacklight_config.add_facet_field 'c'

      expect(subject.blacklight_config.facet_fields.keys).to eq ['c', 'a', 'b']
    end
  end

  describe "index fields" do

    it "should have index fields" do
      expect(subject.index_fields).to be_empty
      subject.index_fields['title'] = {}
      subject.index_fields['author'] = {}
      expect(subject.index_fields.keys).to eq ['title', 'author']
    end

    it "should filter blank values" do
      subject.index_fields['title'] = { something: "" }
      subject.valid?
      expect(subject.index_fields["title"].keys).to_not include :something
    end

    it "should filter the upstream blacklight config" do
      subject.index_fields['a'] = { enabled: true, list: true }
      subject.index_fields['c'] = { enabled: false, list: false }
      subject.index_fields['d'] = { enabled: true, list: true }

      blacklight_config.add_index_field 'a'
      blacklight_config.add_index_field 'b'
      blacklight_config.add_index_field 'c'

      expect(subject.blacklight_config.index_fields).to include('a')
      expect(subject.blacklight_config.index_fields).to_not include('b', 'd')
      expect(subject.blacklight_config.index_fields).to have(1).fields
    end


    it "should include any custom fields" do
      subject.index_fields['a'] = { enabled: true, list: true }
      subject.stub(custom_index_fields: { 'a' => double(merge!: true, validate!: true, normalize!: true) })
      expect(subject.blacklight_config.index_fields).to include('a')
    end

    it "should filter the upstream blacklight config with respect for view types" do
      subject.index_fields['a'] = { enabled: true, list: true, gallery: false }
      subject.index_fields['b'] = { enabled: true, list: false, gallery: true }
      subject.index_fields['c'] = { enabled: false, list: true, gallery: false }
      subject.index_fields['d'] = { enabled: true, list: false, gallery: true }
      subject.index_fields['e'] = { enabled: true, list: true, gallery: false }

      blacklight_config.add_index_field 'a'
      blacklight_config.add_index_field 'b'
      blacklight_config.add_index_field 'c'
      blacklight_config.add_index_field 'd'

      expect(subject.blacklight_config(:list).index_fields).to include('a')
      expect(subject.blacklight_config(:gallery).index_fields).to include('b', 'd')
      expect(subject.blacklight_config(:list).index_fields).to_not include('b', 'd')
      expect(subject.blacklight_config(:gallery).index_fields).to_not include('a', 'c')
      expect(subject.blacklight_config(:list).index_fields).to have(1).fields
      expect(subject.blacklight_config(:gallery).index_fields).to have(2).fields
    end

    it "should filter the upstream blacklight config for show fields" do
      subject.index_fields['a'] = { enabled: true, show: true }
      subject.index_fields['c'] = { enabled: false, show: false }
      subject.index_fields['d'] = { enabled: true, show: false }

      blacklight_config.add_index_field 'a'
      blacklight_config.add_index_field 'b'
      blacklight_config.add_index_field 'c'

      expect(subject.blacklight_config.show_fields).to include('a')
      expect(subject.blacklight_config.show_fields).to_not include('b', 'd')
      expect(subject.blacklight_config.show_fields).to have(1).fields
    end

    it "should include any custom fields" do
      subject.index_fields['a'] = { enabled: true, show: true }

      subject.stub(custom_index_fields: { 'a' => double(merge!: true, validate!: true, normalize!: true) })

      expect(subject.blacklight_config.show_fields).to include('a')
    end

    it "should order the fields by weight" do

      subject.index_fields['a'] = { enabled: true, weight: 3, list: true }
      subject.index_fields['b'] = { enabled: true, weight: 5, list: true }
      subject.index_fields['c'] = { enabled: true, weight: 1, list: true }

      blacklight_config.add_index_field 'a'
      blacklight_config.add_index_field 'b'
      blacklight_config.add_index_field 'c'

      expect(subject.blacklight_config.index_fields.keys).to eq ['c', 'a', 'b']
    end

    it "should order the fields by weight" do

      subject.index_fields['a'] = { enabled: true, weight: 3, show: true }
      subject.index_fields['b'] = { enabled: true, weight: 5, show: true }
      subject.index_fields['c'] = { enabled: true, weight: 1, show: true }

      blacklight_config.add_index_field 'a'
      blacklight_config.add_index_field 'b'
      blacklight_config.add_index_field 'c'

      expect(subject.blacklight_config.show_fields.keys).to eq ['c', 'a', 'b']
    end
  end


  describe "sort fields" do
    it "should have sort fields" do
      expect(subject.sort_fields).to be_empty
      subject.sort_fields['title'] = {}
      subject.sort_fields['author'] = {}
      expect(subject.sort_fields.keys).to eq ['title', 'author']
    end

    it "should filter blank values" do
      subject.sort_fields['title'] = { something: "" }
      subject.valid?
      expect(subject.sort_fields['title'].keys).to_not include :something
    end

    it "should filter the upstream blacklight config" do
      subject.sort_fields['a'] = { enabled: true }
      subject.sort_fields['c'] = { enabled: true }
      subject.sort_fields['d'] = { enabled: true }

      blacklight_config.add_sort_field 'a'
      blacklight_config.add_sort_field 'b'
      blacklight_config.add_sort_field 'c'

      expect(subject.blacklight_config.sort_fields).to include('a', 'c')
      expect(subject.blacklight_config.sort_fields).to_not include('b')
      expect(subject.blacklight_config.sort_fields).to have(2).fields
    end
  end

  describe "per page" do
    it "should have per page configuration" do
      expect(subject.per_page).to be_empty
      subject.per_page << 10 << 50
      expect(subject.per_page).to eq [10, 50]
    end

    it "should filter blank values" do
      subject.per_page << ""
      subject.valid?
      expect(subject.per_page).to_not include ""
    end

    it "should filter the upstream blacklight config" do
      subject.per_page = [10, 50, 1000]
      blacklight_config.per_page = [1, 10, 50, 100]

      expect(subject.blacklight_config.per_page).to eq [10, 50]
    end
  end

  describe "document_index_view_types" do

    it "should have index view configuration" do
      expect(subject.document_index_view_types).to be_empty
      subject.document_index_view_types << 'list' << 'gallery'
      expect(subject.document_index_view_types).to eq ['list', 'gallery']
    end

    it "should filter blank values" do
      subject.document_index_view_types << ""
      subject.valid?
      expect(subject.document_index_view_types).to_not include ""
    end

    it "should filter the upstream blacklight config" do
      subject.document_index_view_types = ['list', 'gallery', 'unknown']
      blacklight_config.view.list
      blacklight_config.view.gallery
      blacklight_config.view.something

      expect(subject.blacklight_config.view.keys).to eq [:list, :gallery]
    end

    it "should pass through the blacklight configuration when not set" do

      blacklight_config.view.list
      blacklight_config.view.gallery
      blacklight_config.view.something
      expect(subject.blacklight_config.view.keys).to eq [:list, :gallery, :something]
    end
  end

  describe "default_solr_params" do
    it "should have default solr params configuration" do
      expect(subject.default_solr_params).to be_empty
      subject.default_solr_params[:qt] = 'custom_request_handler'
      expect(subject.default_solr_params[:qt]).to eq 'custom_request_handler'
    end

    it "should merge with the blacklight config" do
      blacklight_config.default_solr_params = { :qt => 'xyz', :rows => 10 }
      subject.default_solr_params[:qt] = 'abc'
      expect(subject.blacklight_config.default_solr_params).to include(:qt, :rows)
      expect(subject.blacklight_config.default_solr_params[:qt]).to eq 'abc'
    end
  end

  describe "show" do
    it "should have show view configuration" do
      expect(subject.show).to be_empty
      subject.show[:key] = 'some value'
      expect(subject.show[:key]).to eq 'some value'
    end

    it "should merge with the blacklight config" do
      blacklight_config.show.title_field = 'xyz'
      subject.show[:title_field] = 'abc'
      expect(subject.blacklight_config.show.title_field).to eq 'abc'
    end

    it "should inject partials" do
      partials = subject.blacklight_config.show.partials

      expect(partials.first).to eq "spotlight/catalog/curation_mode_toggle"
      expect(partials).to include "spotlight/catalog/tags"
    end
  end

  describe "index" do
    it "should have index view configuration" do
      expect(subject.index).to be_empty
      subject.index[:key] = 'some value'
      expect(subject.index[:key]).to eq 'some value'
    end

    it "should merge with the blacklight config" do
      blacklight_config.index.title_field = 'xyz'
      subject.index[:title_field] = 'abc'
      expect(subject.blacklight_config.index.title_field).to eq 'abc'
    end
  end

  describe "#all_facet_fields" do
    it "should sort the upstream configuration using this config's facet sorting" do
      subject.stub(:field_weight) do |arr, key|
        key
      end

      expect(subject.all_facet_fields.keys).to eq subject.all_facet_fields.keys.sort
    end
  end

  describe "#all_index_fields" do
    it "should sort the upstream configuration using this config's index sorting" do
      subject.stub(:field_weight) do |arr, key|
        key
      end

      expect(subject.all_index_fields.keys).to eq subject.all_index_fields.keys.sort
    end

    it "should include custom index fields" do
      subject.stub(exhibit: double(custom_fields: [
        stub_model(Spotlight::CustomField, field: "abc", configuration: { a: 1}),
        stub_model(Spotlight::CustomField, field: "xyz", configuration: { x: 2})
      ]))

      expect(subject.all_index_fields).to include "abc", "xyz"
    end
  end
  describe "#custom_index_fields" do
    it "should convert exhibit-specific fields to Blacklight configurations" do
      subject.stub(exhibit: double(custom_fields: [
        stub_model(Spotlight::CustomField, field: "abc", configuration: { a: 1}),
        stub_model(Spotlight::CustomField, field: "xyz", configuration: { x: 2})
      ]))

      expect(subject.custom_index_fields).to include 'abc', 'xyz'
      expect(subject.custom_index_fields['abc']).to be_a_kind_of Blacklight::Configuration::SolrField
      expect(subject.custom_index_fields['abc'].a).to eq 1
    end
  end
end