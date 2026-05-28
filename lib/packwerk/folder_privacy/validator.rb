# typed: strict
# frozen_string_literal: true

module Packwerk
  module FolderPrivacy
    class Validator
      include Packwerk::Validator

      Result = Packwerk::Validator::Result

      # @override
      #: (PackageSet package_set, Configuration configuration) -> Result
      def call(package_set, configuration)
        results = [] #: Array[Result]

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

      # @override
      #: -> Array[String]
      def permitted_keys
        %w(enforce_folder_privacy)
      end
    end
  end
end
