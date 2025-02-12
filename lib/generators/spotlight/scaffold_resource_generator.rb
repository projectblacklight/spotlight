# frozen_string_literal: true

require 'rails/generators'

# :nodoc:
module Spotlight
  # spotlight:scaffold_resource generator
  class ScaffoldResource < Rails::Generators::NamedBase
    source_root File.expand_path('templates', __dir__)

    def create_model
      create_file "app/models/#{file_name}_resource.rb", <<~FILE
        class #{class_name}Resource < Spotlight::Resource
          def self.indexing_pipeline
            @indexing_pipeline ||= super.dup.tap do |pipeline|
              # your pipeline here...
            end
          end
        end
      FILE
    end

    def create_controller
      create_file "app/controllers/#{file_name}_resources_controller.rb", <<~FILE
        class #{class_name}ResourcesController < Spotlight::ResourcesController
          private

          def resource_class
            #{class_name}Resource
          end
        end
      FILE
    end

    def create_form
      create_file "app/views/#{file_name}_resources/_form.html.erb", <<~FILE
        <%= bootstrap_form_for([current_exhibit, @resource.becomes(#{class_name}Resource)], as: :resource) do |f| %>
          <%= f.text_field :url  %>
          <div class="form-actions">
            <div class="primary-actions">
              <%= cancel_link @resource, :back, class: 'btn btn-primary' %>
              <%= f.submit t('.add_item'), class: 'btn btn-primary' %>
            </div>
          </div>
        <% end if can? :manage, @resource %>
      FILE
    end
  end

  def inject_configuration
    inject_into_file 'config/initializers/spotlight_initializer.rb' do
      "\n  Spotlight::Engine.config.external_resources_partials += ['#{file_name}_resources/form']\n"
    end
  end

  def create_routes
    route <<~FILE
      resources :exhibits, only: [] do
        resources :#{file_name}_resources, only: [:create, :update] do
        end
      end
    FILE
  end
end
