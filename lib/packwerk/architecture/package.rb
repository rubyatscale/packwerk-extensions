# typed: strict
# frozen_string_literal: true

module Packwerk
  module Architecture
    class Package < T::Struct
      extend T::Sig

      const :layer, T.nilable(String)
      const :enforcement_setting, T.nilable(T.any(T::Boolean, String, T::Array[String]))

      sig { returns(T::Boolean) }
      def enforces?
        enforcement_setting == true || enforcement_setting == 'strict'
      end

      class << self
        extend T::Sig

        sig { params(package: ::Packwerk::Package).returns(Package) }
        def from(package)
          Package.new(
            layer: package.config['layer'],
            enforcement_setting: package.config['enforce_architecture']
          )
        end
      end
    end
  end
end
