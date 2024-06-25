# typed: strict
# frozen_string_literal: true

module Packwerk
  module FolderPrivacy
    class Package < T::Struct
      extend T::Sig

      const :enforce_folder_privacy, T.nilable(T.any(T::Boolean, String))

      class << self
        extend T::Sig

        sig { params(package: ::Packwerk::Package).returns(Package) }
        def from(package)
          Package.new(
            enforce_folder_privacy: package.config['enforce_folder_privacy']
          )
        end
      end
    end
  end
end
