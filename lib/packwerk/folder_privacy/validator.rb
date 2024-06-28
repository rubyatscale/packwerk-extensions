# typed: strict
# frozen_string_literal: true

module Packwerk
  module FolderPrivacy
    class Validator
      extend T::Sig
      include Packwerk::Validator

      Result = Packwerk::Validator::Result

      sig { override.params(package_set: PackageSet, configuration: Configuration).returns(Result) }
      def call(package_set, configuration)
        results = T.let([], T::Array[Result])

        package_manifests_settings_for(configuration, 'enforce_folder_privacy').each do |config, setting|
          next if setting.nil?

          next if [TrueClass, FalseClass].include?(setting.class) || setting == 'strict'

          results << Result.new(
            ok: false,
            error_value: "\tInvalid 'enforce_folder_privacy' option: #{setting.inspect} in #{config.inspect}"
          )
        end

        merge_results(results, separator: "\n---\n")
      end

      sig { override.returns(T::Array[String]) }
      def permitted_keys
        %w[enforce_folder_privacy]
      end
    end
  end
end
