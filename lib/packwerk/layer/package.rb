# typed: strict
# frozen_string_literal: true

module Packwerk
  module Layer
    class Package
      #: String?
      attr_reader :layer

      #: (bool | String | Array[String])?
      attr_reader :enforcement_setting

      #: Hash[untyped, untyped]
      attr_reader :config

      #: (layer: String?, enforcement_setting: (bool | String | Array[String])?, config: Hash[untyped, untyped]) -> void
      def initialize(layer:, enforcement_setting:, config:)
        @layer = layer
        @enforcement_setting = enforcement_setting
        @config = config
      end

      #: -> bool
      def enforces?
        enforcement_setting == true || enforcement_setting == 'strict'
      end

      #: (Package other_package, layers: Layers) -> bool
      def can_depend_on?(other_package, layers:)
        return true if !enforces?

        flow_sensitive_layer = layer
        flow_sensitive_other_layer = other_package.layer
        return true if flow_sensitive_layer.nil?
        return true if flow_sensitive_other_layer.nil?

        layers.index_of(flow_sensitive_layer) >= layers.index_of(flow_sensitive_other_layer)
      end

      class << self
        #: (::Packwerk::Package package, Layers layers) -> Package
        def from(package, layers)
          config = package.config

          # This allows the layer to be inferred based on the package root
          package_root = package.name.split('/').first
          if config['layer']
            layer = config['layer']
          elsif package_root && layers.names.include?(package_root)
            layer = package_root
          else
            layer = nil
          end

          Package.new(
            layer:,
            enforcement_setting: config[Config.new.enforce_key],
            config:
          )
        end
      end
    end
  end
end
