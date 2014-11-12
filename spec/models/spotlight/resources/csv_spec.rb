require 'spec_helper'

describe Spotlight::Resources::Csv, :type => :model do
  let(:exhibit) { FactoryGirl.create :exhibit }
  before do
    allow(Spotlight::SolrDocument).to receive_messages(visibility_field: 'public_bsi')
  end

  describe "#to_solr" do
    let(:csv) do
      [
        { 'id' => 15, 'a' => 1, 'b' => 2, 'extra' => 'ignore'},
        { 'id' => 16, 'a' => 2, 'b' => 3},
      ]
    end

    let(:label_to_field) do
      { 'id' => 'id', 'a' => 'solr_field_a', 'b' => 'custom_field_b' }
    end

    before do
      allow(subject).to receive_messages(csv: csv)
      allow(subject).to receive_messages(label_to_field: label_to_field)
    end

    it "should map csv headers to solr fields" do
      expect(subject.to_solr).to have(2).items
      expect(subject.to_solr.first).to include 'id' => [15], 'solr_field_a' => [1], 'custom_field_b' => [2]
      expect(subject.to_solr.first).to_not include 'extra'
      expect(subject.to_solr.last).to include 'id' => [16], 'solr_field_a' => [2], 'custom_field_b' => [3]
    end
  end

  describe "#label_to_field" do
    let(:blacklight_config) do
      Blacklight::Configuration.new do |config|
        config.index.title_field = 'my_title_field'
        config.add_index_field 'a', label: "Field A"
        config.add_index_field 'b', label: "Field B"

        config.add_facet_field 'c', label: "Field C"
        config.add_facet_field 'd', label: "Field D"
      end

    end

    before do
      allow(subject).to receive_messages(exhibit: double(blacklight_config: blacklight_config))
    end
    it "should include an id and title" do
      expect(subject.label_to_field).to include "id" => "id", "Title" => "my_title_field", "Public" => 'public_bsi'
    end

    it "should include the index fields" do
      expect(subject.label_to_field).to include "Field A" => "a", "Field B" => "b"
    end

    it "should include the facet fields" do
      expect(subject.label_to_field).to include "Field C" => "c", "Field D" => "d"
    end
  end

  describe "#csv" do
    it "should load the uploaded file as CSV" do
      allow(subject).to receive_messages(url: double(path: "/abc"))
      expect(File).to receive(:open).with("/abc", "r").and_return(StringIO.new "a,b\n1,2")
      csv = subject.csv
      expect(csv).to be_a_kind_of CSV
      expect(csv).to have(1).row
    end
  end

  describe "persisting exhibit-specific fields into sidecar rows" do

    let!(:custom_field) { FactoryGirl.create :custom_field, exhibit: exhibit }

    let!(:csv_data) do
      t = Tempfile.new "csv_data"
      t.puts "id,Public,a,b,#{custom_field.label}"
      t.puts "1,true,z,y,x"
      t.puts "2,false,x,v,w"
      t.rewind
      t
    end

    before do
      allow(subject).to receive_messages(reindex: true)
      subject.exhibit = exhibit
      subject.url = csv_data
    end

    it "should create sidecar files for custom fields" do
      expect { subject.save! }.to change { Spotlight::SolrDocumentSidecar.count }.by(2)
      row = subject.exhibit.solr_document_sidecars.where(solr_document_id: "1").first
      expect(row.public).to be_truthy
      expect(row.data[custom_field.field]).to eq "x"
      row = subject.exhibit.solr_document_sidecars.where(solr_document_id: "2").first
      expect(row.public).to be_falsey
      expect(row.data[custom_field.field]).to eq "w"
    end
  end
end
