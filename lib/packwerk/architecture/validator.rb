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

        package_set.each do |package|
          config = package.config
          f = Pathname.new(package.name).join("package.yml").to_s
          next if !config

          result = check_enforce_architecture_setting(f, config['enforce_architecture'])
          results << result
          next if !result.ok?

          result = check_layer_setting(config, f, config['layer'])
          results << result
          next if !result.ok?

          package = Package.from(package, layers)
          results += check_dependencies_setting(package_set, package, f)
        end

        merge_results(results, separator: "\n---\n")
      end

      sig { returns(Layers) }
      def layers
        @layers ||= T.let(Layers.new, T.nilable(Packwerk::Architecture::Layers))
      end

      sig { override.returns(T::Array[String]) }
      def permitted_keys
        %w[enforce_architecture layer]
      end

      sig do
        params(package_set: PackageSet, package: Package, config_file_path: String).returns(T::Array[Result])
      end
      def check_dependencies_setting(package_set, package, config_file_path)
        results = T.let([], T::Array[Result])
        package.config.fetch('dependencies', []).each do |dependency|
          other_packwerk_package = package_set.fetch(dependency)
          next if other_packwerk_package.nil?

          other_package = Package.from(other_packwerk_package, layers)
          next if package.can_depend_on?(other_package, layers: layers)

          results << Result.new(
            ok: false,
            error_value: "Invalid 'dependencies' in #{config_file_path.inspect}. '#{config_file_path}' has a layer type of '#{package.layer},' which cannot rely on '#{other_packwerk_package.name},' which has a layer type of '#{other_package.layer}.' `architecture_layers` can be found in packwerk.yml."
          )
        end

        results
      end

      sig do
        params(config: T::Hash[T.untyped, T.untyped], config_file_path: String, layer: T.untyped).returns(Result)
      end
      def check_layer_setting(config, config_file_path, layer)
        enforce_architecture = config['enforce_architecture']
        enforce_architecture_enabled = !(enforce_architecture.nil? || enforce_architecture == false)
        valid_layer = layer.nil? || layers.names.include?(layer)

        if layer.nil? && enforce_architecture_enabled
          Result.new(
            ok: false,
            error_value: "Invalid 'layer' option in #{config_file_path.inspect}: #{layer.inspect}. `layer` must be set if `enforce_architecture` is on."
          )
        elsif valid_layer
          Result.new(ok: true)
        else
          Result.new(
            ok: false,
            error_value: "Invalid 'layer' option in #{config_file_path.inspect}: #{layer.inspect}. Must be one of #{layers.names.to_a.inspect}"
          )
        end
      end

      sig do
        params(config_file_path: String, setting: T.untyped).returns(Result)
      end
      def check_enforce_architecture_setting(config_file_path, setting)
        valid_value = [true, nil, false, 'strict'].include?(setting)
        layers_set = layers.names.any?
        if valid_value && layers_set
          Result.new(ok: true)
        elsif valid_value
          Result.new(
            ok: false,
            error_value: "Cannot set 'enforce_architecture' option in #{config_file_path.inspect} until `architectural_layers` have been specified in `packwerk.yml`"
          )
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
