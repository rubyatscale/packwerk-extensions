# typed: strict
# frozen_string_literal: true

require 'packwerk/folder_visibility/package'
require 'packwerk/folder_visibility/validator'

module Packwerk
  module FolderVisibility
    class Checker
      extend T::Sig
      include Packwerk::Checker

      VIOLATION_TYPE = T.let('folder_visibility', String)

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
        visibility_package = Package.from(constant_package)
        visibility_option = visibility_package.enforce_folder_visibility
        return false if enforcement_disabled?(visibility_option)

        # p "#{Pathname.new(constant_package.name).dirname} != #{Pathname.new(reference.package.name).dirname}"
        packages_are_siblings = Pathname.new(constant_package.name).dirname == Pathname.new(reference.package.name).dirname
        # p packages_are_siblings
        return false if packages_are_siblings

        return false if reference.package.name == '.'

        reference_is_parent = Pathname.new(constant_package.name).dirname.to_s.start_with?(reference.package.name)
        return false if reference_is_parent

        true
      end

      sig do
        override
          .params(listed_offense: Packwerk::ReferenceOffense)
          .returns(T::Boolean)
      end
      def strict_mode_violation?(listed_offense)
        publishing_package = listed_offense.reference.constant.package
        publishing_package.config['enforce_folder_visibility'] == 'strict'
      end

      sig do
        override
          .params(reference: Packwerk::Reference)
          .returns(String)
      end
      def message(reference)
        source_desc = "'#{reference.package}'"

        message = <<~MESSAGE
          Folder Visibility violation: '#{reference.constant.name}' belongs to '#{reference.constant.package}', which is not visible to #{source_desc} as it is not a sibling pack or parent pack.
          Is there a different package to use instead, or should '#{reference.constant.package}' also be visible to #{source_desc}?

          #{standard_help_message(reference)}
        MESSAGE

        message.chomp
      end

      private

      sig do
        params(visibility_option: T.nilable(T.any(T::Boolean, String)))
          .returns(T::Boolean)
      end
      def enforcement_disabled?(visibility_option)
        [false, nil].include?(visibility_option)
      end

      sig { params(reference: Reference).returns(String) }
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
