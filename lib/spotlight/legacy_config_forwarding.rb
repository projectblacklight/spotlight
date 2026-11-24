# frozen_string_literal: true

module Spotlight
  # Spotlight used to store its settings directly on Spotlight::Engine.config, which
  # is backed by a namespace shared by every Railtie. They now live on
  # Spotlight::Engine.config.spotlight. This module is extended onto the engine's
  # configuration object so that the old style keeps working (with a deprecation
  # warning) for any setting Spotlight defines:
  #
  #   Spotlight::Engine.config.writable_index = false
  #   # => sets Spotlight::Engine.config.spotlight.writable_index
  #
  # TODO: Remove in the next major release.
  module LegacyConfigForwarding
    def self.apply(config, spotlight_options)
      config.extend(self)
      config.instance_variable_set(:@legacy_spotlight_options, spotlight_options)
    end

    private

    def method_missing(name, *, &)
      return super unless legacy_spotlight_key?(name)

      key = name.to_s.delete_suffix('=')
      Spotlight.deprecator.warn(
        "Spotlight::Engine.config.#{key} is deprecated and will be removed in the next major version. " \
        "Use Spotlight::Engine.config.spotlight.#{key} instead."
      )
      @legacy_spotlight_options.public_send(name, *, &)
    end

    def respond_to_missing?(name, include_private = false)
      legacy_spotlight_key?(name) || super
    end

    def legacy_spotlight_key?(name)
      @legacy_spotlight_options&.key?(name.to_s.delete_suffix('=').to_sym)
    end
  end
end
