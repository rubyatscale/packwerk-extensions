# typed: strict
# frozen_string_literal: true

require 'packwerk/architecture/layers'
require 'packwerk/architecture/package'
require 'packwerk/architecture/validator'

module Packwerk
  module Architecture
    # This enforces "layered architecture," which allows each class to be designated as one of N layers
    # configured by the client in `packwerk.yml`, for example:
    #
    # architecture_layers:
    #   - orchestrator
    #   - business_domain
    #   - platform
    #   - utility
    #   - specification
    #
    # Then a package can configure:
    # enforce_architecture: true | false | strict
    # layer: utility
    #
    # This is intended to provide:
    # A) Direction for which dependency violations to tackle
    # B) What dependencies should or should not exist
    # C) A potential sequencing for modularizing a system (starting with lower layers first).
    #
    class Checker
      extend T::Sig
      include Packwerk::Checker

      VIOLATION_TYPE = T.let('architecture', String)

      sig { override.returns(String) }
      def violation_type
        VIOLATION_TYPE
      end

      sig do
        override
          .params(reference: Packwerk::Reference)
          .returns(T::Boolean)
      end
      def invalid_reference?(reference)
        constant_package = Package.from(reference.constant.package, layers)
        referencing_package = Package.from(reference.package, layers)
        !referencing_package.can_depend_on?(constant_package, layers: layers)
      end

      sig do
        override
          .params(listed_offense: Packwerk::ReferenceOffense)
          .returns(T::Boolean)
      end
      def strict_mode_violation?(listed_offense)
        constant_package = listed_offense.reference.package
        constant_package.config['enforce_architecture'] == 'strict'
      end

      sig do
        override
          .params(reference: Packwerk::Reference)
          .returns(String)
      end
      def message(reference)
        constant_package = Package.from(reference.constant.package, layers)
        referencing_package = Package.from(reference.package, layers)

        message = <<~MESSAGE
          Architecture layer violation: '#{reference.constant.name}' belongs to '#{reference.constant.package}', whose architecture layer type is "#{constant_package.layer}."
          This constant cannot be referenced by '#{reference.package}', whose architecture layer type is "#{referencing_package.layer}."
          Can we organize our code logic to respect the layers of these packs? See all layers in packwerk.yml.

          #{standard_help_message(reference)}
        MESSAGE

        message.chomp
      end

      # TODO: Extract this out into a common helper, can call it StandardViolationHelpMessage.new(...) and implements .to_s
      sig { params(reference: Reference).returns(String) }
      def standard_help_message(reference)
        standard_message = <<~MESSAGE.chomp
          Inference details: this is a reference to #{reference.constant.name} which seems to be defined in #{reference.constant.location}.
          To receive help interpreting or resolving this error message, see: https://github.com/Shopify/packwerk/blob/main/TROUBLESHOOT.md#Troubleshooting-violations
        MESSAGE

        standard_message.chomp
      end

      sig { returns(Layers) }
      def layers
        @layers ||= T.let(Layers.new, T.nilable(Packwerk::Architecture::Layers))
      end
    end
  end
end
