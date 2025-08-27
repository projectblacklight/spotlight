# frozen_string_literal: true

module Spotlight
  # Create tag list for exhibit general/create form
  class TagListFormComponent < ViewComponent::Base
    attr_reader :form

    def initialize(form:)
      @form = form
      super()
    end
  end
end
