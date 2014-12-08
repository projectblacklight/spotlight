require 'spec_helper'

describe Spotlight::Appearance, :type => :model do
  let(:config) { FactoryGirl.create(:exhibit).blacklight_configuration }
  subject { Spotlight::Appearance.new config }

  its(:sort_options) { should eq ["title", "type", "date", "source", "identifier"] }

  its(:allowed_params) { should eq [:relevance, :title, :type, :date, :source, :identifier] }

  it "enable_sort_fields" do
    expect(subject.send(:enable_sort_fields, ['title', 'type'])).to eq( { 'sort_title_ssi asc' => {show: true}, 'sort_type_ssi asc' => {show: true}})
  end

  describe '#searchable' do
    it 'should be delegated to the exhibit' do
      expect(config.exhibit).to receive(:searchable)
      subject.searchable
    end
  end

  describe '#exhibit_params' do
    it 'should include the searchable parameter' do
      expect(subject.send(:exhibit_params, searchable: true)).to eq({searchable: true})
    end
    it 'should include the main_navigations_attribute parameter when main_navigations is present' do
      expect(subject.send(:exhibit_params, searchable: false, main_navigations: {a: :a})[:main_navigations_attributes]).to eq([:a])
    end
  end

  describe "#sort_fields" do
    subject { Spotlight::Appearance.new(config).sort_fields }
    describe "when fields are set" do
      before do
        config.sort_fields = {"score desc, sort_title_ssi asc"=> {show: true}, 'sort_type_ssi asc' => {show: true}}
      end
      its(:relevance) { should be_truthy }
      its(:type) { should be_truthy }
      its(:title) { should be_falsey }
    end
  end
end
