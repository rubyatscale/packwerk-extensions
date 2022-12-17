# typed: true
# frozen_string_literal: true

require 'test_helper'

module Packwerk
  module LayeredArchitecture
    class CheckerTest < Minitest::Test
      extend T::Sig
      include FactoryHelper
      include RailsApplicationFixtureHelper

      def write_config
        write_app_file('packwerk.yml', <<~YML)
          architecture_layers:
            - orchestrator
            - business_domain
            - platform
            - utility
            - specification
        YML
      end

      def orchestrator_pack(enforce: false)
        Packwerk::Package.new(name: 'packs/orchestrator', config: { 'enforce_architecture_layer' => enforce, 'metadata' => { 'layer' => 'orchestrator'}})
      end

      def utility_pack(enforce: false)
        Packwerk::Package.new(name: 'packs/utility', config: { 'enforce_architecture_layer' => enforce, 'metadata' => { 'layer' => 'utility'}})
      end

      setup do
        setup_application_fixture
        write_config
      end

      teardown do
        teardown_application_fixture
      end

      test 'ignores if origin package is not enforcing' do
        checker = layered_architecture_checker
        reference = build_reference(
          source_package: utility_pack(enforce: false),
          destination_package: orchestrator_pack(enforce: false)
        )

        refute checker.invalid_reference?(reference)
      end

      test 'is an invalid reference if destination pack is above source package' do
        checker = layered_architecture_checker
        reference = build_reference(
          source_package: utility_pack(enforce: true),
          destination_package: orchestrator_pack(enforce: false)
        )

        assert checker.invalid_reference?(reference)
      end

      test 'is not an invalid reference if destination pack is below source package' do
        checker = layered_architecture_checker
        reference = build_reference(
          source_package: orchestrator_pack(enforce: true),
          destination_package: utility_pack(enforce: false),
        )

        refute checker.invalid_reference?(reference)
      end


      test 'provides a useful message' do
        reference = build_reference(
          source_package: utility_pack(enforce: true),
          destination_package: orchestrator_pack(enforce: false)
        )

        assert_equal layered_architecture_checker.message(build_reference), <<~MSG.chomp
          Architecture layer violation: '::SomeName' belongs to 'packs/orchestrator', whose architecture layer type is "orchestrator."
          This constant cannot be referenced by 'packs/utility', whose architecture layer type is "utility."
          How can we organize our code logic to respect the layers of these packs? See all layers in packwerk.yml.

          Inference details: this is a reference to ::SomeName which seems to be defined in some/location.rb.
          To receive help interpreting or resolving this error message, see: https://github.com/Shopify/packwerk/blob/main/TROUBLESHOOT.md#Troubleshooting-violations
        MSG
      end

      private

      sig { returns(Checker) }
      def layered_architecture_checker
        Visibility::LayeredArchitecture.new
      end
    end
  end
end
