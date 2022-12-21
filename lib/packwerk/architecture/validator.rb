# typed: strict
# frozen_string_literal: true

module Packwerk
  module Architecture
    class Validator
      extend T::Sig
      include Packwerk::Validator

      Result = Packwerk::Validator::Result

      sig { override.params(package_set: PackageSet, configuration: Configuration).returns(Result) }
      def call(package_set, configuration)
        results = T.let([], T::Array[Result])

        architecture_settings = package_manifests_settings_for(configuration, 'enforce_architecture')
        architecture_settings.each do |config_file_path, setting|
          results << check_enforce_architecture_setting(config_file_path, setting)
        end

        merge_results(results, separator: "\n---\n")
      end

      sig { override.returns(T::Array[String]) }
      def permitted_keys
        %w[enforce_architecture layer]
      end

      sig do
        params(config_file_path: String, setting: T.untyped).returns(Result)
      end
      def check_enforce_architecture_setting(config_file_path, setting)
        if [true, nil, false, 'strict'].include?(setting)
          Result.new(ok: true)
        else
          Result.new(
            ok: false,
            error_value: "Invalid 'enforce_architecture' option in #{config_file_path.inspect}: #{setting.inspect}"
          )
        end
      end
    end
  end
end
