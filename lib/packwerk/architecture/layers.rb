# typed: strict
# frozen_string_literal: true

module Packwerk
  module Architecture
    class Layers
      extend T::Sig

      sig { void }
      def initialize
        @names = T.let(@names, T.nilable(T::Array[String]))
      end

      sig { params(layer: String).returns(Integer) }
      def index_of(layer)
        index = names.reverse.find_index(layer)
        if index.nil?
          raise "Layer #{layer} not find, please run `bin/packwerk validate`"
        end

        index
      end

      sig { returns(T::Array[String]) }
      def names
        @names ||= YAML.load_file('packwerk.yml')['architecture_layers'] || []
      end
    end
  end
end
