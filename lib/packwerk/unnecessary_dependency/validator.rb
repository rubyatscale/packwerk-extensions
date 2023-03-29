# typed: strict
# frozen_string_literal: true

module Packwerk
  module UnnecessaryDependency
    class Validator
      extend T::Sig
      include Packwerk::Validator

      Result = Packwerk::Validator::Result

      sig { override.params(package_set: PackageSet, configuration: Configuration).returns(Result) }
      def call(package_set, configuration)
        results = T.let([], T::Array[Result])
        return Result.new(ok: true) if !YAML.load_file('packwerk.yml')['prevent_unnecessary_dependencies']
        return Result.new(ok: true) if !Checker::DEPENDENCIES_YML.exist?

        dependencies = YAML.load_file(Checker::DEPENDENCIES_YML)
        package_set.each do |package|
          config = package.config
          f = Pathname.new(package.name).join('package.yml').to_s
          next if !config

          used_dependencies = dependencies.fetch(package.name, [])
          listed_dependencies = package.config.fetch('dependencies', [])
          unnecessary_dependencies = listed_dependencies - used_dependencies
          next unless unnecessary_dependencies.any?

          results << Result.new(
            ok: false,
            error_value: "Invalid 'dependencies' in #{f}. '#{f}' has unnecessary dependencies #{unnecessary_dependencies.inspect}"
          )
        end

        merge_results(results, separator: "\n---\n")
      end

      sig { override.returns(T::Array[String]) }
      def permitted_keys
        []
      end
    end
  end
end
