# typed: strict
# frozen_string_literal: true

module Packwerk
  module FolderPrivacy
    class Package
      #: (bool | String)?
      attr_reader :enforce_folder_privacy

      #: (enforce_folder_privacy: (bool | String)?) -> void
      def initialize(enforce_folder_privacy:)
        @enforce_folder_privacy = enforce_folder_privacy
      end

      class << self
        #: (::Packwerk::Package package) -> Package
        def from(package)
          Package.new(
            enforce_folder_privacy: package.config['enforce_folder_privacy']
          )
        end
      end
    end
  end
end
