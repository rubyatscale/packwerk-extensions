# typed: strict
# frozen_string_literal: true

module Packwerk
  module Layer
    class Config
      extend T::Sig

      ARCHITECTURE_VIOLATION_TYPE = T.let('architecture', String)
      ARCHITECTURE_ENFORCE = T.let('enforce_architecture', String)
      LAYER_VIOLATION_TYPE = T.let('layer', String)
      LAYER_ENFORCE = T.let('enforce_layers', String)

      sig { void }
      def initialize
        @layers_key_configured = T.let(@layers_key_configured, T.nilable(T::Boolean))
        @layers_list = T.let(@layers_list, T.nilable(T::Array[String]))
      end

      sig { returns(T::Array[String]) }
      def layers_list
        @layers_list ||= YAML.load_file('packwerk.yml')[layers_key] || []
      end

      sig { returns(T::Boolean) }
      def layers_key_configured?
        @layers_key_configured ||= YAML.load_file('packwerk.yml')['architecture_layers'].nil?
      end

      sig { returns(String) }
      def layers_key
        layers_key_configured? ? 'layers' : 'architecture_layers'
      end

      sig { returns(String) }
      def violation_key
        layers_key_configured? ? LAYER_VIOLATION_TYPE : ARCHITECTURE_VIOLATION_TYPE
      end

      sig { returns(String) }
      def enforce_key
        layers_key_configured? ? LAYER_ENFORCE : ARCHITECTURE_ENFORCE
      end
    end
  end
end
