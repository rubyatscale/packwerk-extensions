# typed: strict
# frozen_string_literal: true

module Packwerk
  module Privacy
    class Package
      #: String
      attr_reader :public_path

      #: String?
      attr_reader :user_defined_public_path

      #: (bool | String)?
      attr_reader :enforce_privacy

      #: Array[String]
      attr_reader :private_constants

      #: Array[String]
      attr_reader :ignored_private_constants

      #: Array[String]
      attr_reader :strict_privacy_ignored_patterns

      #: (
      #|   public_path: String,
      #|   user_defined_public_path: String?,
      #|   enforce_privacy: (bool | String)?,
      #|   private_constants: Array[String],
      #|   ignored_private_constants: Array[String],
      #|   strict_privacy_ignored_patterns: Array[String]
      #| ) -> void
      def initialize(
        public_path:,
        user_defined_public_path:,
        enforce_privacy:,
        private_constants:,
        ignored_private_constants:,
        strict_privacy_ignored_patterns:
      )
        @public_path = public_path
        @user_defined_public_path = user_defined_public_path
        @enforce_privacy = enforce_privacy
        @private_constants = private_constants
        @ignored_private_constants = ignored_private_constants
        @strict_privacy_ignored_patterns = strict_privacy_ignored_patterns
      end

      #: (String path) -> bool
      def public_path?(path)
        path.start_with?(public_path)
      end

      class << self
        #: (::Packwerk::Package package) -> Package
        def from(package)
          Package.new(
            public_path: public_path_for(package),
            user_defined_public_path: user_defined_public_path(package),
            enforce_privacy: package.config['enforce_privacy'],
            private_constants: package.config['private_constants'] || [],
            ignored_private_constants: package.config['ignored_private_constants'] || [],
            strict_privacy_ignored_patterns: package.config['strict_privacy_ignored_patterns'] || []
          )
        end

        #: (::Packwerk::Package package) -> String?
        def user_defined_public_path(package)
          return unless package.config['public_path']
          return package.config['public_path'] if package.config['public_path'].end_with?('/')

          "#{package.config['public_path']}/"
        end

        #: (::Packwerk::Package package) -> String
        def public_path_for(package)
          unprefixed_public_path = user_defined_public_path(package) || 'app/public/'

          if package.root?
            unprefixed_public_path
          else
            File.join(package.name, unprefixed_public_path)
          end
        end
      end
    end
  end
end
