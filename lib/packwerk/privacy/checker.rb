# typed: strict
# frozen_string_literal: true

require 'packwerk/privacy/package'
require 'packwerk/privacy/validator'

module Packwerk
  module Privacy
    # Checks whether a given reference references a private constant of another package.
    class Checker
      include Packwerk::Checker

      VIOLATION_TYPE = 'privacy'
      PUBLICIZED_SIGIL = 'pack_public: true'
      PUBLICIZED_SIGIL_REGEX = /pack_public:\s*true/
      @publicized_locations = {} #: Hash[String, bool]

      class << self
        #: Hash[String, bool]
        attr_reader :publicized_locations

        #: (String location) -> bool
        def publicized_location?(location)
          unless publicized_locations.key?(location)
            publicized_locations[location] = check_for_publicized_sigil(location)
          end

          publicized_locations.fetch(location)
        end

        #: (String location) -> bool
        def check_for_publicized_sigil(location)
          content_contains_sigil?(File.readlines(location))
        end

        #: (Array[String] lines) -> bool
        def content_contains_sigil?(lines)
          lines.first(5).any? do |l|
            # Only the sigil's existence matters, so it is enough to look for it after the
            # line's first `#`. Searching from there keeps the scan linear in the length of
            # the line, where matching `/#.*pack_public:\s*true/` would retry the `.*` scan
            # once per `#` in the line.
            comment_start = l.index('#')
            !comment_start.nil? && PUBLICIZED_SIGIL_REGEX.match?(l, comment_start + 1)
          end
        end
      end

      # @override
      #: -> String
      def violation_type
        VIOLATION_TYPE
      end

      # @override
      #: (Packwerk::Reference reference) -> bool
      def invalid_reference?(reference)
        constant_package = reference.constant.package
        privacy_package = Package.from(constant_package)

        return false if privacy_package.public_path?(reference.constant.location)
        return false if self.class.publicized_location?(reference.constant.location)

        privacy_option = privacy_package.enforce_privacy
        return false if enforcement_disabled?(privacy_option)

        return false if privacy_package.ignored_private_constants.include?(reference.constant.name)

        explicitly_private_constant?(reference.constant, explicitly_private_constants: privacy_package.private_constants)
      end

      # @override
      #: (Packwerk::ReferenceOffense listed_offense) -> bool
      def strict_mode_violation?(listed_offense)
        publishing_package = listed_offense.reference.constant.package

        return false unless publishing_package.config['enforce_privacy'] == 'strict'
        return false if exclude_from_strict?(
          publishing_package.config['strict_privacy_ignored_patterns'] || [],
          Pathname.new(listed_offense.reference.relative_path).cleanpath
        )

        true
      end

      # @override
      #: (Packwerk::Reference reference) -> String
      def message(reference)
        source_desc = "'#{reference.package}'"

        message = <<~MESSAGE
          Privacy violation: '#{reference.constant.name}' is private to '#{reference.constant.package}' but referenced from #{source_desc}.
          Is there a public entrypoint in '#{Package.from(reference.constant.package).public_path}' that you can use instead?

          #{standard_help_message(reference)}
        MESSAGE

        message.chomp
      end

      private

      #: (ConstantContext constant, explicitly_private_constants: Array[String]) -> bool
      def explicitly_private_constant?(constant, explicitly_private_constants:)
        return true if explicitly_private_constants.empty?

        explicitly_private_constants.include?(constant.name) ||
          # nested constants
          explicitly_private_constants.any? { |epc| constant.name.start_with?("#{epc}::") }
      end

      #: ((bool | String | Array[String])? privacy_option) -> bool
      def enforcement_disabled?(privacy_option)
        [false, nil].include?(privacy_option)
      end

      #: (Reference reference) -> String
      def standard_help_message(reference)
        standard_message = <<~MESSAGE.chomp
          Inference details: this is a reference to #{reference.constant.name} which seems to be defined in #{reference.constant.location}.
          To receive help interpreting or resolving this error message, see: https://github.com/Shopify/packwerk/blob/main/TROUBLESHOOT.md#Troubleshooting-violations
        MESSAGE

        standard_message.chomp
      end

      #: (Array[String] globs, Pathname path) -> bool
      def exclude_from_strict?(globs, path)
        globs.any? do |glob|
          path.fnmatch(glob, File::FNM_EXTGLOB)
        end
      end
    end
  end
end
