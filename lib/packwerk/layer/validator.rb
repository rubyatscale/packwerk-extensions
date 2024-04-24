# typed: strict
# frozen_string_literal: true

module Packwerk
  module Layer
    class Validator
      extend T::Sig
      include Packwerk::Validator

      Result = Packwerk::Validator::Result

      sig { override.params(package_set: PackageSet, configuration: Configuration).returns(Result) }
      def call(package_set, configuration)
        results = T.let([], T::Array[Result])

        package_set.each do |package|
          config = package.config
          f = Pathname.new(package.name).join('package.yml').to_s
          next if !config

          result = check_enforce_layers_setting(f, config['enforce_layers'])
          results << result
          next if !result.ok?

          package = Package.from(package, layers)

          result = check_layer_setting(package, f)
          results << result
          next if !result.ok?
        end

        merge_results(results, separator: "\n---\n")
      end

      sig { returns(Layers) }
      def layers
        @layers ||= T.let(Layers.new, T.nilable(Packwerk::Layer::Layers))
      end

      sig { override.returns(T::Array[String]) }
      def permitted_keys
        %w[enforce_layers layer]
      end

      sig do
        params(package: Package, config_file_path: String).returns(Result)
      end
      def check_layer_setting(package, config_file_path)
        layer = package.layer
        valid_layer = layer.nil? || layers.names.include?(layer)

        if layer.nil? && package.enforces?
          Result.new(
            ok: false,
            error_value: "Invalid 'layer' option in #{config_file_path.inspect}: #{package.layer.inspect}. `layer` must be set if `enforce_layers` is on."
          )
        elsif valid_layer
          Result.new(ok: true)
        else
          Result.new(
            ok: false,
            error_value: "Invalid 'layer' option in #{config_file_path.inspect}: #{layer.inspect}. Must be one of #{layers.names_list.inspect}"
          )
        end
      end

      sig do
        params(config_file_path: String, setting: T.untyped).returns(Result)
      end
      def check_enforce_layers_setting(config_file_path, setting)
        activated_value = [true, 'strict'].include?(setting)
        valid_value = [true, nil, false, 'strict'].include?(setting)
        layers_set = layers.names.any?
        if !valid_value
          Result.new(
            ok: false,
            error_value: "Invalid 'enforce_layers' option in #{config_file_path.inspect}: #{setting.inspect}"
          )
        elsif activated_value && !layers_set
          Result.new(
            ok: false,
            error_value: "Cannot set 'enforce_layers' option in #{config_file_path.inspect} until `layers` have been specified in `packwerk.yml`"
          )
        else
          Result.new(ok: true)
        end
      end
    end
  end
end
