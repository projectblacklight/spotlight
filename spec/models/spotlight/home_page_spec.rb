require 'spec_helper'

describe Spotlight::HomePage, type: :model do
  let(:home_page) { FactoryGirl.create(:home_page) }
  it { is_expected.not_to be_feature_page }
  it { is_expected.not_to be_about_page }
  it 'displays the sidebar' do
    expect(home_page.display_sidebar?).to be_truthy
  end
  it 'is published' do
    expect(home_page.published).to be_truthy
  end
  describe 'title' do
    it 'includes default text' do
      expect(home_page.title).to eq described_class.default_title_text
    end
  end
  describe 'should_display_title?' do
    it 'returns the display_title attribute' do
      home_page.display_title = true
      expect(home_page.should_display_title?).to be_truthy
      home_page.display_title = false
      expect(home_page.should_display_title?).to be_falsey
    end
  end
  describe 'display_sidebar?' do
    it 'is false when the page disabled the display_sidebar' do
      home_page.display_sidebar = false
      expect(home_page.display_sidebar?).to be_falsey
    end
  end
end
