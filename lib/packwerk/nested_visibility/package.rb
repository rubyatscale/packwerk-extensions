# typed: strict
# frozen_string_literal: true

module Packwerk
  module NestedVisibility
    class Package < T::Struct
      extend T::Sig

      const :enforce_nested_visibility, T.nilable(T.any(T::Boolean, String))

      class << self
        extend T::Sig

        sig { params(package: ::Packwerk::Package).returns(Package) }
        def from(package)
          Package.new(
            enforce_nested_visibility: package.config['enforce_nested_visibility']
          )
        end
      end
    end
  end
end
