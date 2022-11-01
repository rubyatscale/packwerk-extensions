# typed: strict
# frozen_string_literal: true

module Packwerk
  module Privacy
    # Checks whether a given reference references a private constant of another package.
    class Checker
      extend T::Sig
      include CheckerInterface

      VIOLATION_TYPE = T.let('privacy', String)

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
        constant_package = reference.constant.package
        privacy_package = Package.from(constant_package)

        return false if privacy_package.public_path?(reference.constant.location)

        privacy_option = Package.from(constant_package).enforce_privacy
        return false if enforcement_disabled?(privacy_option)

        return false unless privacy_option == true ||
                            explicitly_private_constant?(reference.constant, explicitly_private_constants: T.unsafe(privacy_option))

        true
      end

      sig do
        override
          .params(reference: Packwerk::Reference)
          .returns(String)
      end
      def message(reference)
        source_desc = "'#{reference.source_package}'"

        message = <<~MESSAGE
          Privacy violation: '#{reference.constant.name}' is private to '#{reference.constant.package}' but referenced from #{source_desc}.
          Is there a public entrypoint in '#{Package.from(reference.constant.package).public_path}' that you can use instead?

          #{standard_help_message(reference)}
        MESSAGE

        message.chomp
      end

      private

      sig do
        params(
          constant: ConstantDiscovery::ConstantContext,
          explicitly_private_constants: T::Array[String]
        ).returns(T::Boolean)
      end
      def explicitly_private_constant?(constant, explicitly_private_constants:)
        explicitly_private_constants.include?(constant.name) ||
          # nested constants
          explicitly_private_constants.any? { |epc| constant.name.start_with?(epc + '::') }
      end

      sig do
        params(privacy_option: T.nilable(T.any(T::Boolean, T::Array[String])))
          .returns(T::Boolean)
      end
      def enforcement_disabled?(privacy_option)
        [false, nil].include?(privacy_option)
      end
    end
  end
end
