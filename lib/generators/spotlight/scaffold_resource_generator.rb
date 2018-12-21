require 'rails/generators'

# :nodoc:
module Spotlight
  # spotlight:scaffold_resource generator
  class ScaffoldResource < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    def create_document_builder
      create_file "app/services/#{file_name}_builder.rb", <<-FILE.strip_heredoc
        class #{class_name}Builder < Spotlight::SolrDocumentBuilder
          def to_solr
            return to_enum(:to_solr) unless block_given?

            # TODO: your implementation here
            # yield { id: resource.id }
          end
        end
      FILE
    end

    def create_model
      create_file "app/models/#{file_name}_resource.rb", <<-FILE.strip_heredoc
        class #{class_name}Resource < Spotlight::Resource
          self.document_builder_class = #{class_name}Builder
        end
      FILE
    end

    def create_controller
      create_file "app/controllers/#{file_name}_resources_controller.rb", <<-FILE.strip_heredoc
        class #{class_name}ResourcesController < Spotlight::ResourcesController
          private

          def resource_class
            #{class_name}Resource
          end
        end
      FILE
    end

    def create_form
      create_file "app/views/#{file_name}_resources/_form.html.erb", <<-FILE.strip_heredoc
      <%= bootstrap_form_for([current_exhibit, @resource.becomes(#{class_name}Resource)], as: :resource) do |f| %>
        <%= f.text_field :url  %>
        <div class="form-actions">
          <div class="primary-actions">
            <%= cancel_link @resource, :back, class: 'btn btn-secondary' %>
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
    route <<-FILE.strip_heredoc
      resources :exhibits, only: [] do
        resources :#{file_name}_resources, only: [:create, :update] do
        end
      end
    FILE
  end
end
