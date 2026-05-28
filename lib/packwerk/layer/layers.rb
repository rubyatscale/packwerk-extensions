# typed: strict
# frozen_string_literal: true

module Packwerk
  module Layer
    class Layers
      #: (String layer) -> Integer
      def index_of(layer)
        index = names_list.reverse.find_index(layer)
        if index.nil?
          raise "Layer #{layer} not find, please run `bin/packwerk validate`"
        end

        index
      end

      #: -> Set[String]
      def names
        @names ||= Set.new(names_list) #: Set[String]?
      end

      #: -> Array[String]
      def names_list
        @names_list ||= Config.new.layers_list #: Array[String]?
      end
    end
  end
end
