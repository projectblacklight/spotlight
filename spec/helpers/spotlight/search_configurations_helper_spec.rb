require 'spec_helper'

describe Spotlight::SearchConfigurationsHelper, type: :helper do
  describe '#translate_sort_fields' do
    let(:sort_config) do
      Blacklight::OpenStructWithHashAccess.new(sort: 'score asc, sort_title_ssi desc')
    end

    it 'translates sort fields' do
      expect(translate_sort_fields(sort_config)).to eq 'relevancy score ascending and title descending'
    end

    it 'humanizes untranslatable sort fields' do
      sort_config.sort = 'some_other_field desc'

      expect(translate_sort_fields(sort_config)).to eq 'some other field descending'
    end

    it 'supports explicit sort descriptions' do
      sort_config.sort_description = 'xyz'
      expect(translate_sort_fields(sort_config)).to eq 'xyz'
    end
  end
end
