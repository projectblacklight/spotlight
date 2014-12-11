require 'spec_helper'

describe Spotlight::AppearancesHelper, type: :helper do
  describe "#translate_sort_fields" do
    let(:sort_config) {
      Blacklight::OpenStructWithHashAccess.new({sort: "score asc, sort_title_ssi desc"})
    }
    it 'should translate sort fields' do
      expect(translate_sort_fields(sort_config)).to eq 'relevancy score ascending, title descending'
    end
  end
end
