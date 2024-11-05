# frozen_string_literal: true

require 'ostruct'

module SirTrevorRails
  # Forked from (former) upstream sir-trevor-rails 0.6.2 gem:
  # https://github.com/madebymany/sir-trevor-rails/blob/931b9554f5268158b4da8817477cdc82e4e2e69c/lib/sir_trevor_rails/block.rb
  # Copyright (c) 2013-2014 by ITV plc - http://www.itv.com
  class Block < OpenStruct
    DEFAULT_FORMAT = :markdown

    def self.from_hash(hash, parent = nil)
      hash = hash.deep_dup.with_indifferent_access
      type_klass(hash).new(hash, parent)
    end

    def format
      send(:[], :format).present? ? send(:[], :format).to_sym : DEFAULT_FORMAT
    end

    def alt_text?
      self.class.alt_text?
    end

    def self.alt_text?
      false
    end

    # Sets a list of custom block types to speed up lookup at runtime.
    def self.custom_block_types
      # You can define your custom block types directly here or in your engine config.
      Spotlight::Engine.config.sir_trevor_widgets
    end

    def self.custom_block_type_alt_text_settings
      custom_block_types.index_with { |block_type| SirTrevorRails::Block.block_class(block_type).alt_text? }
    end

    def initialize(hash, parent)
      @raw_data = hash
      @parent  = parent
      @type    = hash[:type].to_sym
      super(hash[:data])
    end

    attr_reader :parent, :type

    def to_partial_path
      "sir_trevor/blocks/#{self.class.name.demodulize.underscore}"
    end

    def as_json(*_attrs)
      {
        type: @type.to_s,
        data: marshal_dump
      }
    end

    # Infers the block class.
    # Safe lookup that tries to identify user created block class.
    #
    # @param [Symbol] type
    def self.block_class(type)
      type_name = type.to_s.camelize
      block_name = "#{type_name}Block"
      if custom_block_types.include?(type_name)
        begin
          block_name.constantize
        rescue NameError
          block_class!(block_name)
        end
      else
        block_class!(block_name)
      end
    end

    # Infers the block class.
    # Failover from block_class.
    # Safe lookup against the SirTevor::Blocks namespace
    # If no block is found, create one with given name and inherit from Block class
    #
    # @param [Constant] block_name
    def self.block_class!(block_name)
      SirTrevorRails::Blocks.const_get(block_name)
    rescue NameError
      SirTrevorRails::Blocks.const_set(block_name, Class.new(Block))
    end

    def self.type_klass(hash)
      if self == Block
        block_class(hash[:type].to_sym)
      else
        self
      end
    end
  end
end
