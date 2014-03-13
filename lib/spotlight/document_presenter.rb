# WHEN Blacklight 5.2 comes out this should inherit from Blacklight::DocumentPresenter
module Spotlight
  class DocumentPresenter < Blacklight::DocumentPresenter

    def raw_document_heading
      Array(@document[@configuration.view_config(:show).title_field]).join(field_value_separator) || @document.id
    end

  end
end
