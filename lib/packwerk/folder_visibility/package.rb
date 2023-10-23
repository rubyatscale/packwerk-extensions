# typed: strict
# frozen_string_literal: true

module Packwerk
  module FolderVisibility
    class Package < T::Struct
      extend T::Sig

      const :enforce_folder_visibility, T.nilable(T.any(T::Boolean, String))

      class << self
        extend T::Sig

        sig { params(package: ::Packwerk::Package).returns(Package) }
        def from(package)
          Package.new(
            enforce_folder_visibility: package.config['enforce_folder_visibility']
          )
        end
      end
    end
  end
end
