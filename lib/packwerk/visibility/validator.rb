# typed: strict
# frozen_string_literal: true

module Packwerk
  module Visibility
    class Validator
      include Packwerk::Validator

      Result = Packwerk::Validator::Result

      # @override
      #: (PackageSet package_set, Configuration configuration) -> Result
      def call(package_set, configuration)
        visible_settings = package_manifests_settings_for(configuration, 'visible_to')
        results = [] #: Array[Result]

        all_package_names = package_set.to_set(&:name)

        package_manifests_settings_for(configuration, 'enforce_visibility').each do |config, setting|
          next if setting.nil?

          next if [TrueClass, FalseClass].include?(setting.class) || setting == 'strict'

          results << Result.new(
            ok: false,
            error_value: "\tInvalid 'enforce_visibility' option: #{setting.inspect} in #{config.inspect}"
          )
        end

        visible_settings.each do |config_file_path, setting|
          next if setting.nil?

          if setting.is_a?(Array)
            packages_not_found = setting.to_set - all_package_names

            if packages_not_found.any?
              results << Result.new(
                ok: false,
                error_value: "'visible_to' option must only contain valid packages in #{config_file_path.inspect}. Invalid packages: #{packages_not_found.to_a.inspect}"
              )
            end
          else
            results << Result.new(
              ok: false,
              error_value: "'visible_to' option must be an array in #{config_file_path.inspect}."
            )
          end
        end

        merge_results(results, separator: "\n---\n")
      end

      # @override
      #: -> Array[String]
      def permitted_keys
        %w(visible_to enforce_visibility)
      end
    end
  end
end
