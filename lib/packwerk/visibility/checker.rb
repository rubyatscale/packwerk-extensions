# typed: strict
# frozen_string_literal: true

require 'packwerk/visibility/package'
require 'packwerk/visibility/validator'

module Packwerk
  module Visibility
    # Checks whether a given reference references a constant from a package that does not permit visibility
    class Checker
      include Packwerk::Checker

      VIOLATION_TYPE = 'visibility'

      # @override
      #: -> String
      def violation_type
        VIOLATION_TYPE
      end

      # @override
      #: (Packwerk::Reference reference) -> bool
      def invalid_reference?(reference)
        constant_package = reference.constant.package
        visibility_package = Package.from(constant_package)
        visibility_option = visibility_package.enforce_visibility
        return false if enforcement_disabled?(visibility_option)

        !visibility_package.visible_to.include?(reference.package.name)
      end

      # @override
      #: (Packwerk::ReferenceOffense listed_offense) -> bool
      def strict_mode_violation?(listed_offense)
        publishing_package = listed_offense.reference.constant.package
        publishing_package.config['enforce_visibility'] == 'strict'
      end

      # @override
      #: (Packwerk::Reference reference) -> String
      def message(reference)
        source_desc = "'#{reference.package}'"

        message = <<~MESSAGE
          Visibility violation: '#{reference.constant.name}' belongs to '#{reference.constant.package}', which is not visible to #{source_desc}.
          Is there a different package to use instead, or should '#{reference.constant.package}' also be visible to #{source_desc}?

          #{standard_help_message(reference)}
        MESSAGE

        message.chomp
      end

      private

      #: ((bool | String)? visibility_option) -> bool
      def enforcement_disabled?(visibility_option)
        [false, nil].include?(visibility_option)
      end

      #: (Reference reference) -> String
      def standard_help_message(reference)
        standard_message = <<~MESSAGE.chomp
          Inference details: this is a reference to #{reference.constant.name} which seems to be defined in #{reference.constant.location}.
          To receive help interpreting or resolving this error message, see: https://github.com/Shopify/packwerk/blob/main/TROUBLESHOOT.md#Troubleshooting-violations
        MESSAGE

        standard_message.chomp
      end
    end
  end
end
