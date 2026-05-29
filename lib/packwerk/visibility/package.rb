# typed: strict
# frozen_string_literal: true

module Packwerk
  module Visibility
    class Package
      #: Array[String]
      attr_reader :visible_to

      #: (bool | String)?
      attr_reader :enforce_visibility

      #: (visible_to: Array[String], enforce_visibility: (bool | String)?) -> void
      def initialize(visible_to:, enforce_visibility:)
        @visible_to = visible_to
        @enforce_visibility = enforce_visibility
      end

      class << self
        #: (::Packwerk::Package package) -> Package
        def from(package)
          Package.new(
            visible_to: package.config['visible_to'] || [],
            enforce_visibility: package.config['enforce_visibility']
          )
        end
      end
    end
  end
end
