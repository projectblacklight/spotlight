require "spec_helper"

describe "Catalog", :type => :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as curator }


  describe "admin" do
    
    before do
      d = SolrDocument.new(id: 'dq287tq6352')
      d.make_private! exhibit
      d.reindex
      Blacklight.solr.commit
    end
    
    after do
      d = SolrDocument.new(id: 'dq287tq6352')
      d.make_public! exhibit
      d.reindex
      Blacklight.solr.commit
    end

    it "should have a 'Item Visiblity' facet" do
      visit spotlight.exhibit_catalog_index_path(exhibit)
      expect(page).to have_selector '.panel-title', text: "Item Visibility"
    end
  end
end
