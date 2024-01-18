# typed: strict
# frozen_string_literal: true

module Packwerk
  module ServiceBoundary
    class Package < T::Struct
      extend T::Sig

      const :enforce_service_boundary, T.nilable(T.any(T::Boolean, String))

      class << self
        extend T::Sig

        sig { params(package: ::Packwerk::Package).returns(Package) }
        def from(package)
          Package.new(
            enforce_service_boundary: package.config['enforce_service_boundary']
          )
        end
      end
    end
  end
end
