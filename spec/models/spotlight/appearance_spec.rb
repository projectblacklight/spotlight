require 'spec_helper'

describe Spotlight::Appearance, :type => :model do
  let(:config) { FactoryGirl.create(:exhibit).blacklight_configuration }
  subject { Spotlight::Appearance.new config }

  describe '#allowed_params' do
    it 'should include all the sort types and the settable options' do
      [:relevance, :title, :type, :date, :source, :identifier].each do |sort|
        expect(subject.allowed_params[sort]). to eq [:enabled, :label, :weight]
      end
    end
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
        config.sort_fields = {"relevance"=> {enabled: true}, 'type' => {enabled: true}}
      end
      it 'should be true' do
        expect(subject[:relevance][:enabled]).to be_truthy
        expect(subject[:type][:enabled]).to be_truthy
        expect(subject[:title][:enabled]).to be_falsey
      end
    end
  end
end
