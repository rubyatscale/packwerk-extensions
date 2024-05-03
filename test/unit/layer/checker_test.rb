# typed: true
# frozen_string_literal: true

require 'test_helper'

module Packwerk
  module Layer
    class CheckerTest < Minitest::Test
      extend T::Sig
      include FactoryHelper
      include RailsApplicationFixtureHelper

      def write_config
        write_app_file('packwerk.yml', <<~YML)
          layers:
            - orchestrator
            - business_domain
            - platform
            - utility
            - specification
        YML
      end

      def orchestrator_pack(enforce: false)
        Packwerk::Package.new(name: 'packs/orchestrator', config: { 'enforce_layers' => enforce, 'layer' => 'orchestrator' })
      end

      def utility_pack(enforce: false)
        Packwerk::Package.new(name: 'packs/utility', config: { 'enforce_layers' => enforce, 'layer' => 'utility' })
      end

      setup do
        setup_application_fixture
        use_template(:minimal)
        write_config
      end

      teardown do
        teardown_application_fixture
      end

      test 'determines violation type' do
        assert_equal layer_checker.violation_type, 'layer'
      end

      test 'ignores if origin package is not enforcing' do
        checker = layer_checker
        reference = build_reference(
          source_package: utility_pack(enforce: false),
          destination_package: orchestrator_pack(enforce: false)
        )

        refute checker.invalid_reference?(reference)
      end

      test 'is an invalid reference if destination pack is above source package' do
        checker = layer_checker
        reference = build_reference(
          source_package: utility_pack(enforce: true),
          destination_package: orchestrator_pack(enforce: false)
        )

        assert checker.invalid_reference?(reference)
      end

      test 'infers layer based on root directory' do
        orchestrator_pack = Packwerk::Package.new(name: 'orchestrator/some_pack', config: { 'enforce_layers' => true })
        utility_pack = Packwerk::Package.new(name: 'utility/some_other_pack', config: { 'enforce_layers' => true })
        checker = layer_checker
        reference = build_reference(
          source_package: utility_pack,
          destination_package: orchestrator_pack
        )

        assert_equal Package.from(orchestrator_pack, Layers.new).layer, 'orchestrator'
        assert_equal Package.from(utility_pack, Layers.new).layer, 'utility'
        assert checker.invalid_reference?(reference)
      end

      test 'allows layer setting to override root directory location' do
        orchestrator_pack = Packwerk::Package.new(name: 'orchestrator/some_pack', config: { 'layer' => 'specification', 'enforce_layers' => true })
        utility_pack = Packwerk::Package.new(name: 'utility/some_other_pack', config: { 'enforce_layers' => true })
        checker = layer_checker
        reference = build_reference(
          source_package: utility_pack,
          destination_package: orchestrator_pack
        )

        assert_equal Package.from(orchestrator_pack, Layers.new).layer, 'specification'
        assert_equal Package.from(utility_pack, Layers.new).layer, 'utility'
        refute checker.invalid_reference?(reference)
      end

      test 'is not an invalid reference if destination pack is below source package' do
        checker = layer_checker
        reference = build_reference(
          source_package: orchestrator_pack(enforce: true),
          destination_package: utility_pack(enforce: false)
        )

        refute checker.invalid_reference?(reference)
      end

      test 'provides a useful message' do
        reference = build_reference(
          source_package: utility_pack(enforce: true),
          destination_package: orchestrator_pack(enforce: false)
        )

        assert_equal layer_checker.message(reference), <<~MSG.chomp
          Layer violation: '::SomeName' belongs to 'packs/orchestrator', whose layer type is "orchestrator".
          This constant cannot be referenced by 'packs/utility', whose layer type is "utility".
          Packs in a lower layer may not access packs in a higher layer. See the `layers` in packwerk.yml. Current hierarchy:
          - orchestrator
          - business_domain
          - platform
          - utility
          - specification

          Inference details: this is a reference to ::SomeName which seems to be defined in some/location.rb.
          To receive help interpreting or resolving this error message, see: https://github.com/Shopify/packwerk/blob/main/TROUBLESHOOT.md#Troubleshooting-violations
        MSG
      end

      private

      sig { returns(Checker) }
      def layer_checker
        Packwerk::Layer::Checker.new
      end
    end
  end
end
