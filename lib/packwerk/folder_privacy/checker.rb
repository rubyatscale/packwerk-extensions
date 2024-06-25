# typed: strict
# frozen_string_literal: true

require 'packwerk/folder_privacy/package'
require 'packwerk/folder_privacy/validator'

module Packwerk
  module FolderPrivacy
    class Checker
      extend T::Sig
      include Packwerk::Checker

      VIOLATION_TYPE = T.let('folder_privacy', String)

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
        referencing_package = reference.package
        referenced_package = reference.constant.package

        return false if enforcement_disabled?(Package.from(referenced_package).enforce_folder_privacy)

        # the root pack is parent folder of all packs, so we short-circuit this here
        referencing_package_is_root_pack = referencing_package.name == '.'
        return false if referencing_package_is_root_pack

        packages_are_sibling_folders = Pathname.new(referenced_package.name).dirname == Pathname.new(referencing_package.name).dirname
        return false if packages_are_sibling_folders

        referencing_package_is_parent_folder = Pathname.new(referenced_package.name).to_s.start_with?(referencing_package.name)
        return false if referencing_package_is_parent_folder

        true
      end

      sig do
        override
          .params(listed_offense: Packwerk::ReferenceOffense)
          .returns(T::Boolean)
      end
      def strict_mode_violation?(listed_offense)
        publishing_package = listed_offense.reference.constant.package
        publishing_package.config['enforce_folder_privacy'] == 'strict'
      end

      sig do
        override
          .params(reference: Packwerk::Reference)
          .returns(String)
      end
      def message(reference)
        source_desc = "'#{reference.package}'"

        message = <<~MESSAGE
          Folder Privacy violation: '#{reference.constant.name}' belongs to '#{reference.constant.package}', which is private to #{source_desc} as it is not a sibling pack or parent pack.
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
