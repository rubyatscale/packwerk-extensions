# typed: strict
# frozen_string_literal: true

require 'packwerk/unnecessary_dependency/validator'
require 'pathname'
require 'yaml'

module Packwerk
  module UnnecessaryDependency
    # This, in conjunction with the Validator, looks for unnecessary dependencies
    # listed in your package.yml files.
    class Checker
      extend T::Sig
      include Packwerk::Checker

      VIOLATION_TYPE = T.let('unnecessary_dependency', String)
      DEPENDENCIES_YML = Pathname.new('tmp/packwerk/dependencies.yml')

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
        existing_references = if DEPENDENCIES_YML.exist?
                                YAML.load_file(DEPENDENCIES_YML)
                              else
                                FileUtils.mkdir_p(DEPENDENCIES_YML.dirname)
                                {}
                              end

        existing_references[reference.package.name] ||= []
        existing_references[reference.package.name] << reference.constant.package.name
        DEPENDENCIES_YML.write(existing_references.to_yaml)

        false
      end

      sig do
        override
          .params(listed_offense: Packwerk::ReferenceOffense)
          .returns(T::Boolean)
      end
      def strict_mode_violation?(listed_offense)
        false
      end

      sig do
        override
          .params(reference: Packwerk::Reference)
          .returns(String)
      end
      def message(reference)
        ''
      end
    end
  end
end
