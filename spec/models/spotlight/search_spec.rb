require 'spec_helper'

describe Spotlight::Search, :type => :model do
  let(:query_params) { {"f"=>{"genre_sim"=>["map"]}} }
  subject { FactoryGirl.build(:search, query_params: query_params )}

  let(:blacklight_config) { ::CatalogController.blacklight_config }

  it { is_expected.to be_a Spotlight::Catalog::AccessControlsEnforcement }

  it "should have a default feature image" do
    allow(subject).to receive_messages(documents: [SolrDocument.new(id: 'dq287tq6352', blacklight_config.index.title_field => 'title', Spotlight::Engine.config.full_image_field => "https://stacks.stanford.edu/image/dq287tq6352/dq287tq6352_05_0001_thumb")])
    subject.save!
    expect(subject.thumbnail).not_to be_nil
    expect(subject.thumbnail.image.path).to end_with "dq287tq6352_05_0001_thumb.jpeg"
  end

  it "should have items" do
    expect(subject.count).to eq 55
  end

  it "should have images" do
    expect(subject.images.size).to eq(55)
    expect(subject.images.map(&:last)).to include "https://stacks.stanford.edu/image/dq287tq6352/dq287tq6352_05_0001_thumb", "https://stacks.stanford.edu/image/jp266yb7109/jp266yb7109_05_0001_thumb"
  end

  describe "default_scope" do
    let!(:page1) { FactoryGirl.create(:search, weight: 5, on_landing_page: true) }
    let!(:page2) { FactoryGirl.create(:search, weight: 1, on_landing_page: true) }
    let!(:page3) { FactoryGirl.create(:search, weight: 10, on_landing_page: true) }
    it "should order by weight" do
      expect(Spotlight::Search.published.map(&:weight)).to eq [1, 5, 10]
    end
  end
end
