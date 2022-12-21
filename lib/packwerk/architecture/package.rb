# typed: strict
# frozen_string_literal: true

module Packwerk
  module Architecture
    class Package < T::Struct
      extend T::Sig

      const :layer, T.nilable(String)
      const :enforcement_setting, T.nilable(T.any(T::Boolean, String, T::Array[String]))
      const :config, T::Hash[T.untyped, T.untyped]

      sig { returns(T::Boolean) }
      def enforces?
        enforcement_setting == true || enforcement_setting == 'strict'
      end

      sig { params(other_package: Package, layers: Layers).returns(T::Boolean) }
      def can_depend_on?(other_package, layers:)
        return true if !enforces?

        flow_sensitive_layer = layer
        flow_sensitive_other_layer = other_package.layer
        return true if flow_sensitive_layer.nil?
        return true if flow_sensitive_other_layer.nil?

        layers.index_of(flow_sensitive_layer) >= layers.index_of(flow_sensitive_other_layer)
      end

      class << self
        extend T::Sig

        sig { params(package: ::Packwerk::Package).returns(Package) }
        def from(package)
          from_config(package.config)
        end

        sig { params(config: T::Hash[T.untyped, T.untyped]).returns(Package) }
        def from_config(config)
          Package.new(
            layer: config['layer'],
            enforcement_setting: config['enforce_architecture'],
            config: config
          )
        end
      end
    end
  end
end