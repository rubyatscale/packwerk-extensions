# typed: strict
# frozen_string_literal: true

module Packwerk
  module Visibility
    class Package < T::Struct
      extend T::Sig

      const :visible_to, T::Array[String]
      const :enforce_visibility, T.nilable(T.any(T::Boolean, String))

      class << self
        extend T::Sig

        sig { params(package: ::Packwerk::Package).returns(Package) }
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
