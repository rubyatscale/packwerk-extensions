# typed: strict
# frozen_string_literal: true

module Packwerk
  module Architecture
    class Layers
      extend T::Sig

      sig { void }
      def initialize
        @names = T.let(@names, T.nilable(T::Set[String]))
        @names_list = T.let(@names_list, T.nilable(T::Array[String]))
      end

      sig { params(layer: String).returns(Integer) }
      def index_of(layer)
        index = names_list.reverse.find_index(layer)
        if index.nil?
          raise "Layer #{layer} not find, please run `bin/packwerk validate`"
        end

        index
      end

      sig { returns(T::Set[String]) }
      def names
        @names ||= Set.new(names_list)
      end

      private

      sig { returns(T::Array[String]) }
      def names_list
        @names_list ||= YAML.load_file('packwerk.yml')['architecture_layers'] || []
      end
    end
  end
end
