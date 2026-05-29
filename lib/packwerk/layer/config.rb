# typed: strict
# frozen_string_literal: true

module Packwerk
  module Layer
    class Config
      ARCHITECTURE_VIOLATION_TYPE = 'architecture'
      ARCHITECTURE_ENFORCE = 'enforce_architecture'
      LAYER_VIOLATION_TYPE = 'layer'
      LAYER_ENFORCE = 'enforce_layers'

      #: -> Array[String]
      def layers_list
        @layers_list ||= YAML.load_file('packwerk.yml')[layers_key] || [] #: Array[String]?
      end

      #: -> bool
      def layers_key_configured?
        @layers_key_configured ||= YAML.load_file('packwerk.yml')['architecture_layers'].nil? #: bool?
      end

      #: -> String
      def layers_key
        layers_key_configured? ? 'layers' : 'architecture_layers'
      end

      #: -> String
      def violation_key
        layers_key_configured? ? LAYER_VIOLATION_TYPE : ARCHITECTURE_VIOLATION_TYPE
      end

      #: -> String
      def enforce_key
        layers_key_configured? ? LAYER_ENFORCE : ARCHITECTURE_ENFORCE
      end
    end
  end
end
