require 'spec_helper'

describe Spotlight::Site do
  subject { described_class.instance }

  describe '.instance' do
    it 'is a singleton' do
      expect(described_class.instance).to eq described_class.instance
    end
  end

  describe '#tags' do
    let!(:exhibit_a) { FactoryGirl.create(:exhibit, tag_list: 'a', site: subject) }
    let!(:exhibit_b) { FactoryGirl.create(:exhibit, tag_list: 'a', site: subject) }

    it 'deduplicates the tag results' do
      expect(subject.tags.length).to eq 1
    end
  end

  describe '#tag_list' do
    let!(:exhibit_a) { FactoryGirl.create(:exhibit, tag_list: 'a', site: subject) }
    let!(:exhibit_b) { FactoryGirl.create(:exhibit, tag_list: 'b', site: subject) }

    it 'aggregates all the tags for the exhibits' do
      expect(subject.tag_list).to match_array %w(a b)
    end
  end

  describe '#tags_attributes=' do
    let!(:exhibit_a) { FactoryGirl.create(:exhibit, tag_list: 'a', site: subject) }
    let(:tag) { { id: subject.tags.first.id, name: 'x' }.with_indifferent_access }

    it 'ignores new tags' do
      expect(subject.update(tags_attributes: [{ name: 'x' }])).to eq true
      expect(subject.tag_list).not_to include 'x'
    end

    it 'renames existing tags' do
      expect(subject.update(tags_attributes: [tag])).to eq true
      expect(subject.tag_list).not_to include 'a'
      expect(subject.tag_list).to include 'x'
    end
  end

  describe '#autosave_associated_records_for_tags' do
    let!(:exhibit_a) { FactoryGirl.create(:exhibit, tag_list: 'a', site: subject) }
    let(:tag) { { id: subject.tags.first.id, name: 'a' }.with_indifferent_access }

    it 'removes tags marked for destruction' do
      expect(subject.update(tags_attributes: [tag.merge('_destroy' => '1')])).to eq true
      expect(subject.tag_list).not_to include 'a'
    end
  end
end
