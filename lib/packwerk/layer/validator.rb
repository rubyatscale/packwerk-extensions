# typed: strict
# frozen_string_literal: true

module Packwerk
  module Layer
    class Validator
      include Packwerk::Validator

      Result = Packwerk::Validator::Result

      # @override
      #: (PackageSet package_set, Configuration configuration) -> Result
      def call(package_set, configuration)
        results = [] #: Array[Result]

        package_set.each do |package|
          config = package.config
          f = Pathname.new(package.name).join('package.yml').to_s
          package = Package.from(package, layers)

          next if !config

          result = check_enforce_key(package, f, config)
          results << result
          next if !result.ok?

          result = check_enforce_layers_setting(f, config[layer_config.enforce_key])
          results << result
          next if !result.ok?

          result = check_layer_setting(package, f)
          results << result
          next if !result.ok?
        end

        merge_results(results, separator: "\n---\n")
      end

      #: -> Layers
      def layers
        @layers ||= Layers.new #: Packwerk::Layer::Layers?
      end

      #: -> Config
      def layer_config
        @layer_config ||= Config.new #: Config?
      end

      # @override
      #: -> Array[String]
      def permitted_keys
        [layer_config.enforce_key, 'layer']
      end

      #: (Package package, String config_file_path, Hash[untyped, untyped] config) -> Result
      def check_enforce_key(package, config_file_path, config)
        enforce_layer_present = !config[Config::LAYER_ENFORCE].nil?
        enforce_architecture_present = !config[Config::ARCHITECTURE_ENFORCE].nil?

        if layer_config.enforce_key == Config::LAYER_ENFORCE && enforce_architecture_present
          Result.new(
            ok: false,
            error_value: "Unexpected `enforce_architecture` option in #{config_file_path.inspect}. Did you mean `enforce_layers`?"
          )
        elsif layer_config.enforce_key == Config::ARCHITECTURE_ENFORCE && enforce_layer_present
          Result.new(
            ok: false,
            error_value: "Unexpected `enforce_layers` option in #{config_file_path.inspect}. Did you mean `enforce_architecture`?"
          )
        else
          Result.new(ok: true)
        end
      end

      #: (Package package, String config_file_path) -> Result
      def check_layer_setting(package, config_file_path)
        layer = package.layer
        valid_layer = layer.nil? || layers.names.include?(layer)

        if layer.nil? && package.enforces?
          Result.new(
            ok: false,
            error_value: "Invalid 'layer' option in #{config_file_path.inspect}: #{package.layer.inspect}. `layer` must be set if `#{layer_config.enforce_key}` is on."
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

      #: (String config_file_path, untyped setting) -> Result
      def check_enforce_layers_setting(config_file_path, setting)
        activated_value = [true, 'strict'].include?(setting)
        valid_value = [true, nil, false, 'strict'].include?(setting)
        layers_set = layers.names.any?
        if !valid_value
          Result.new(
            ok: false,
            error_value: "Invalid '#{layer_config.enforce_key}' option in #{config_file_path.inspect}: #{setting.inspect}"
          )
        elsif activated_value && !layers_set
          Result.new(
            ok: false,
            error_value: "Cannot set '#{layer_config.enforce_key}' option in #{config_file_path.inspect} until `layers` have been specified in `packwerk.yml`"
          )
        else
          Result.new(ok: true)
        end
      end
    end
  end
end
