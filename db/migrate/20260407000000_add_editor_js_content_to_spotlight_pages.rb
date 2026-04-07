# frozen_string_literal: true

class AddEditorJsContentToSpotlightPages < ActiveRecord::Migration[7.1]
  def change
    add_column :spotlight_pages, :editor_js_content, :text
  end
end
