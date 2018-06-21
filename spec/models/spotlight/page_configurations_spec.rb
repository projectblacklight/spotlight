# frozen_string_literal: true

describe Spotlight::PageConfigurations, type: :model do
  let(:view_context) do
    double(
      'ViewContext',
      available_view_fields: [],
      current_exhibit: exhibit,
      blacklight_config: exhibit.blacklight_config,
      document_show_link_field: 'document_show_link_field',
      index_field_label: 'index_field_label',
      index_fields: [],
      spotlight: spotlight,
      t: 'translated-content'
    )
  end

  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:page) { FactoryBot.create(:feature_page, exhibit: exhibit) }
  subject(:page_config) { described_class.new(context: view_context, page: page) }

  describe '#as_json' do
    it 'is a json-able object (hash)' do
      expect(page_config.as_json).to be_a Hash
    end
  end

  describe 'downstream configured_params' do
    it 'merges the supplied hash into the configs' do
      expect(page_config).to receive_messages(configured_params: { 'hello': 'goodbye' })

      expect(page_config.as_json).to include('hello': 'goodbye')
    end

    it 'sends the #call method to the value if it can respond (e.g. a lamda)' do
      expect(view_context).to receive_messages(my_custom_plugin_path: 'my_custom_plugin/data.json')
      expect(page_config).to receive_messages(
        configured_params: { 'my-custom-plugin-path': ->(config) { config.context.my_custom_plugin_path } }
      )

      expect(page_config.as_json).to include('my-custom-plugin-path': 'my_custom_plugin/data.json')
    end
  end
end
