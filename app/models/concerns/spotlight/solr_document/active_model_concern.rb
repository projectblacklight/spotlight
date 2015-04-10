module Spotlight
  module SolrDocument
    ##
    # ActiveModel stubs to make {::SolrDocument}s work as activemodel objects
    module ActiveModelConcern
      extend ActiveSupport::Concern

      included do
        include Spotlight::ArLight
        extend ActiveModel::Callbacks
        define_model_callbacks :save
      end

      def save
        run_callbacks :save do
          # no-op
        end
      end

      def to_key
        [id]
      end

      def persisted?
        true
      end

      def destroyed?
        false
      end

      def new_record?
        !persisted?
      end
    end
  end
end
