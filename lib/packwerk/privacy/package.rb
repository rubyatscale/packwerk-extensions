# typed: strict
# frozen_string_literal: true

module Packwerk
  module Privacy
    class Package < T::Struct
      extend T::Sig

      const :public_path, String
      const :user_defined_public_path, T.nilable(String)
      const :enforce_privacy, T.nilable(T.any(T::Boolean, String))
      const :private_constants, T::Array[String]
      const :ignored_private_constants, T::Array[String]
      const :strict_privacy_ignored_patterns, T::Array[String]

      sig { params(path: String).returns(T::Boolean) }
      def public_path?(path)
        path.start_with?(public_path)
      end

      class << self
        extend T::Sig

        sig { params(package: ::Packwerk::Package).returns(Package) }
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

        sig { params(package: ::Packwerk::Package).returns(T.nilable(String)) }
        def user_defined_public_path(package)
          return unless package.config['public_path']
          return package.config['public_path'] if package.config['public_path'].end_with?('/')

          "#{package.config['public_path']}/"
        end

        sig { params(package: ::Packwerk::Package).returns(String) }
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
