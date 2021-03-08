# frozen_string_literal: true

# Migrate caption fields for the document title (pointing at the solr field name) to use the
# new `Spotlight::PageConfigurations::DOCUMENT_TITLE_KEY` for run-time lookups instead.
class MigrateCaptionValuesForTitleKey < ActiveRecord::Migration[5.2]
  def up
    Spotlight::Page.reset_column_information
    change_caption_field_of(Spotlight::Page, from: CatalogController.blacklight_config.index.title_field, to: Spotlight::PageConfigurations::DOCUMENT_TITLE_KEY)
  end

  def down
    Spotlight::Page.reset_column_information
    change_caption_field_of(Spotlight::Page, from: Spotlight::PageConfigurations::DOCUMENT_TITLE_KEY, to: CatalogController.blacklight_config.index.title_field)
  end

  def change_caption_field_of(scope, from:, to:)
    scope.find_each do |page|
      changed = false

      page.content.select { |block| block['primary-caption-field'] == from || block['secondary-caption-field'] == from }.each do |block|
        changed = true
        block['primary-caption-field'] = to if block['primary-caption-field'] == from
        block['secondary-caption-field'] = to if block['secondary-caption-field'] == from
      end

      page.update(content: page.content) if changed
    end
  end
end
