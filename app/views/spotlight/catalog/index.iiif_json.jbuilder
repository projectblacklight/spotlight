# frozen_string_literal: true

json.set! :@context, 'http://iiif.io/api/presentation/2/context.json'
json.set! :@id, exhibit_iiif_collection_url(page: params[:page]&.to_i)
json.set! :@type, 'sc:Collection'
json.label current_exhibit.title
json.viewingHint 'top'
json.description current_exhibit.description if current_exhibit.description
json.manifests do
  json.array!(@response.documents) do |doc|
    next unless doc.first(Spotlight::Engine.config.iiif_manifest_field)

    json.set! :@id, doc.first(Spotlight::Engine.config.iiif_manifest_field)
    json.set! :@type, 'sc:manifest'
    json.label document_presenter(doc).heading
  end
end

json.total @response.total
json.first exhibit_iiif_collection_url(page: nil)

json.next exhibit_iiif_collection_url(page: @response.next_page) unless @response.last_page? || @response.out_of_range?
