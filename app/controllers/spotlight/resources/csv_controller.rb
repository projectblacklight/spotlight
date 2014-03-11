require 'csv'

module Spotlight::Resources
  class CsvController < Spotlight::ResourcesController
    before_filter :build_resource, only: [:new, :create, :template]

    load_and_authorize_resource class: 'Spotlight::Resources::Csv', instance_name: 'resource'

    def template
      render text: CSV.generate { |csv| csv << @resource.label_to_field.keys }
    end

    protected
    def build_resource
      @resource ||= Spotlight::Resources::Csv.new exhibit: @exhibit
    end

    def resource_params
      params.require(:resource_csv).permit!
    end

  end
end
