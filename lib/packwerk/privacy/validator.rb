# typed: strict
# frozen_string_literal: true

module Packwerk
  module Privacy
    class Validator
      extend T::Sig
      include Packwerk::Validator

      Result = Packwerk::Validator::Result

      sig { override.params(package_set: PackageSet, configuration: Configuration).returns(Result) }
      def call(package_set, configuration)
        privacy_settings = package_manifests_settings_for(configuration, 'enforce_privacy')

        results = T.let([], T::Array[Result])

        privacy_settings.each do |config_file_path, setting|
          results << check_enforce_privacy_setting(config_file_path, setting)
        end

        public_path_settings = package_manifests_settings_for(configuration, 'public_path')
        public_path_settings.each do |config_file_path, setting|
          results << check_public_path(config_file_path, setting)
        end

        merge_results(results, separator: "\n---\n")
      end

      sig { override.returns(T::Array[String]) }
      def permitted_keys
        %w[public_path enforce_privacy]
      end

      private

      sig do
        params(config_file_path: String, setting: T.untyped).returns(Result)
      end
      def check_public_path(config_file_path, setting)
        if setting.is_a?(String) || setting.nil?
          Result.new(ok: true)
        else
          Result.new(
            ok: false,
            error_value: "'public_path' option must be a string in #{config_file_path.inspect}: #{setting.inspect}"
          )
        end
      end

      sig do
        params(config_file_path: String, setting: T.untyped).returns(Result)
      end
      def check_enforce_privacy_setting(config_file_path, setting)
        if [TrueClass, FalseClass, Array, NilClass].include?(setting.class) || setting == 'strict'
          Result.new(ok: true)
        else
          Result.new(
            ok: false,
            error_value: "Invalid 'enforce_privacy' option in #{config_file_path.inspect}: #{setting.inspect}"
          )
        end
      end
    end
  end
end
