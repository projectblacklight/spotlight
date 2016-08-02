module Spotlight
  # Draws DOM elements for working with crop.es6.
  # These consist of:
  #   1) hidden field that associates the image to the parent
  #   2) IIIF URL for the image (crop coordinates)
  #   3) File upload field
  #   4) div for OpenSeadragon to use
  class IIIFCropper
    def initialize(form, name, width, height)
      @form = form
      @name = name
      @width = width
      @height = height
      @base = form.object.model_name.param_key
      @association = form.object.association(name)
      @foreign_key = association.reflection.foreign_key
      @model = association.reflection.klass.model_name
      @selector = "#{model.param_key}_image"
    end

    attr_reader :base, :association, :form, :name, :model, :foreign_key, :selector

    # Draws the complete set of DOM elements.
    #   1) association to the parent
    #   2) IIIF URL for the image
    #   3) File upload field
    #   4) div for openseadragon
    def draw
      hidden_field.concat(nested_form)
    end

    # Draws just the IIIF URL field and the div for openseadragon
    def text_and_display(image_form)
      text = image_form.text_field :iiif_url, size: 120
      text.concat(display)
    end

    # Draws just the file upload field
    def upload(image_form)
      image_form.file_field_without_bootstrap :file, data: data_attributes
    end

    # Draws just the association to the parent
    def hidden_field
      form.hidden_field foreign_key
    end

    private

    # @return the ActionView context
    def template
      @template ||= form.instance_variable_get(:@template)
    end

    def data_attributes
      {
        endpoint: template.polymorphic_path(model.route_key),
        tilesource: association.reader.persisted? ? template.riiif.info_url(association.reader.id) : nil,
        croppable: true,
        initial_set_select: [0, 0, @width, @height],
        association: association_dom_id,
        selector: selector,
        url: url_dom_id
      }
    end

    def nested_form
      nested = nil
      form.fields_for(name) do |image_form|
        nested = upload(image_form).concat(text_and_display(image_form))
      end
      nested
    end

    # Returns the DOM element id that holds the association between the parent
    # object and the image
    def association_dom_id
      "#{base}_#{foreign_key}"
    end

    # Returns the DOM element id that holds the iiif url
    def url_dom_id
      "#{base}_#{name}_attributes_iiif_url"
    end

    def display
      template.content_tag :div, '', id: selector, class: 'osd-container'
    end
  end
end
