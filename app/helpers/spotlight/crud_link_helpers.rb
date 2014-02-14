module Spotlight
  module CrudLinkHelpers
    def cancel_link model, *args
      link_to_options = args.extract_options!
      link = args.first
      link_to action_default_value(model, :cancel), link, link_to_options
    end

    def view_link model, *args
      link_to_options = args.extract_options!
      link = args.first || [spotlight, model]
      link_to action_default_value(model, :view), link, link_to_options
    end

    def create_link model, *args
      link_to_options = args.extract_options!
      link = args.first || [spotlight, :new, model]
      link_to action_default_value(model), link, link_to_options
    end

    def edit_link model, *args
      link_to_options = args.extract_options!
      link = args.first || [spotlight, :edit, model]
      link_to action_default_value(model), link, link_to_options
    end

    def delete_link model, *args
      link_to_options = args.extract_options!
      link = args.first || [spotlight, model]
      default_options = { method: :delete, data: { confirm: action_default_value(model, :destroy_are_you_sure) } }
      link_to action_default_value(model, :destroy), link, default_options.merge(link_to_options)
    end

    def action_label model, action
      action_default_value model, action
    end

    private

    def action_default_value object, key = nil
      object_model = convert_to_model(object)

      key ||= object_model ? (object_model.persisted? ? :edit : :create) : :view
      
      case object_model
      when ActsAsTaggableOn::Tag
        model = :tag
        object_name = :tag
      when Symbol, String
        model = object_model
        object_name = object_model
      else
        model = object_model.class.model_name.human
        object_name = object_model.class.model_name.i18n_key
      end

      defaults = []
      defaults << :"helpers.action.#{object_name}.#{key}"
      defaults << :"helpers.action.#{key}"
      defaults << "#{key.to_s.humanize} #{model}"
      I18n.t(defaults.shift, model: model, default: defaults)
    end
  end
end