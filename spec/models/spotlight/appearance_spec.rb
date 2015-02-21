require 'spec_helper'

describe Spotlight::Appearance, :type => :model do
  let(:config) { FactoryGirl.create(:exhibit).blacklight_configuration }
  subject { Spotlight::Appearance.new config }

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

  describe "#view_type_options" do
    subject { Spotlight::Appearance.new(config).view_type_options }
    it "should include the available view types" do
      expect(subject).to include :list, :gallery, :slideshow
    end

    it "should not include rss or atom" do
      expect(subject).not_to include :rss, :atom
    end
  end
end
