require 'spec_helper'

describe Spotlight::Page, type: :model do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let!(:parent_page) { Spotlight::FeaturePage.create! exhibit: exhibit, published: true }
  let!(:child_page) { Spotlight::FeaturePage.create! exhibit: exhibit, published: false, parent_page: parent_page }

  describe '.at_top_level' do
    it 'scopes results to only top level pages' do
      expect(described_class.at_top_level).to_not include child_page
    end
  end

  describe '.published' do
    it 'scopes results to only published pages' do
      expect(described_class.at_top_level).to_not include child_page
    end
  end

  describe '#top_level_page?' do
    it 'checks if the page is a top-level page' do
      expect(parent_page).to be_a_top_level_page
      expect(child_page).not_to be_a_top_level_page
    end
  end

  describe '#top_level_page_or_self' do
    it 'fetches the top level page' do
      expect(child_page.top_level_page_or_self).to be parent_page
    end

    it 'is the same object if the page is a top level page' do
      expect(parent_page.top_level_page_or_self).to be parent_page
    end
  end
  describe '.display_sidebar' do
    it 'is set to true by default' do
      expect(parent_page.display_sidebar?).to be_truthy
    end
  end
  describe 'should_display_title?' do
    let(:page) { FactoryGirl.create(:feature_page) }
    it 'returns if the title is present or not' do
      expect(page.title).not_to be_blank
      expect(page.should_display_title?).to be_truthy
      page.title = ''
      expect(page.should_display_title?).to be_falsey
    end
  end

  describe '#content=' do
    let(:page) { FactoryGirl.create(:feature_page) }

    it 'works with a serialized JSON array' do
      page.content = [].to_json
      expect(page.content).to be_a_kind_of SirTrevorRails::BlockArray
    end
    it 'works with an array' do
      page.content = []
      expect(page.content).to be_a_kind_of SirTrevorRails::BlockArray
    end
  end

  describe '#content?' do
    let(:page) { FactoryGirl.create(:feature_page) }

    it 'does not have content when the page is empty' do
      page.content = []
      expect(page).not_to have_content
    end

    it 'has content when the page has a widget' do
      page.content = [{ type: 'rule' }]
      expect(page).to have_content
    end
  end

  describe '#slug' do
    let(:page) { FactoryGirl.create(:feature_page) }

    it 'gets a default slug' do
      expect(page.slug).not_to be_blank
    end

    it 'is updated when the title changes' do
      page.update(title: 'abc')
      expect(page.slug).to eq 'abc'
    end

    context 'with a custom slug' do
      let(:page) { FactoryGirl.create(:feature_page, slug: 'xyz') }

      it 'gets a default slug' do
        expect(page.slug).to eq 'xyz'
      end
    end
  end
end
