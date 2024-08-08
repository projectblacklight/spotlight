# frozen_string_literal: true

module Spotlight
  # Displays the document
  # This overrides the title method to provide an edit link.
  class DocumentComponent < Blacklight::DocumentComponent
    def title
      return safe_join([exhibit_edit_link, super, add_document_meta_content(@document)]) if current_exhibit

      super
    end

    attr_reader :document

    delegate :current_exhibit, :can?, :add_document_meta_content, to: :helpers

    def exhibit_edit_link
      helpers.exhibit_edit_link document, [:edit, current_exhibit, document], class: 'float-right float-end btn btn-primary' if can?(:curate, current_exhibit)
    end
  end
end
