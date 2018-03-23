# frozen_string_literal: true

RSpec.describe Spotlight::TranslationsHelper do
  describe '#non_custom_metadata_fields' do
    let(:exhibit) { FactoryBot.create(:exhibit) }
    let!(:custom_field) { FactoryBot.create(:custom_field, exhibit: exhibit) }

    before { allow(helper).to receive(:current_exhibit).and_return(exhibit) }

    it "is an array of the current exhibit's metadata fields with the custom fields removed" do
      expect(exhibit.blacklight_config.show_fields.keys).to include custom_field.field

      expect(helper.non_custom_metadata_fields.keys).not_to include custom_field.field
    end
  end
end
