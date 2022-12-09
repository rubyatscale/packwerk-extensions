# typed: strict
# frozen_string_literal: true

module Packwerk
  module Visibility
    class Validator
      extend T::Sig
      include Packwerk::Validator

      sig { override.params(package_set: PackageSet, configuration: Configuration).returns(ApplicationValidator::Result) }
      def call(package_set, configuration)
        visible_settings = package_manifests_settings_for(configuration, 'visible_to')
        results = T.let([], T::Array[ApplicationValidator::Result])

        all_package_names = package_set.map(&:name).to_set
        
        visible_settings.each do |config_file_path, setting|
          next if setting.nil?
          if !setting.is_a?(Array)
            results << ApplicationValidator::Result.new(
              ok: false,
              error_value: "'visible_to' option must be an array in #{config_file_path.inspect}."
            )
          else
            packages_not_found = setting.to_set - all_package_names

            if packages_not_found.any?
              results << ApplicationValidator::Result.new(
                ok: false,
                error_value: "'visible_to' option must only contain valid packages in #{config_file_path.inspect}. Invalid packages: #{packages_not_found.inspect}"
              )
            end
          end
        end

        merge_results(results, separator: "\n---\n")
      end

      sig { override.returns(T::Array[String]) }
      def permitted_keys
        %w[visible_to enforce_visibility]
      end
    end
  end
end
