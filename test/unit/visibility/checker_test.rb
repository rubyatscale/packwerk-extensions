# typed: true
# frozen_string_literal: true

require 'test_helper'

module Packwerk
  module Visibility
    class CheckerTest < Minitest::Test
      extend T::Sig
      include FactoryHelper
      include RailsApplicationFixtureHelper

      setup do
        setup_application_fixture
      end

      teardown do
        teardown_application_fixture
      end

      test 'ignores if destination package is not enforcing' do
        checker = visibility_checker
        reference = build_reference

        refute checker.invalid_reference?(reference)
      end

      test 'is an invalid reference if destination pack is not visible to reference pack' do
        checker = visibility_checker
        destination_package = Packwerk::Package.new(
          name: 'destination_package',
          config: { 'enforce_visibility' => true, visible_to: 'other_pack' }
        )
        reference = build_reference(destination_package: destination_package)

        assert checker.invalid_reference?(reference)
      end

      test 'is not an invalid reference if destination pack is visible to reference pack' do
        checker = visibility_checker
        destination_package = Packwerk::Package.new(
          name: 'destination_package',
          config: { 'enforce_visibility' => true, 'visible_to' => ['components/source'] }
        )
        reference = build_reference(destination_package: destination_package)

        refute checker.invalid_reference?(reference)
      end

      test 'provides a useful message' do
        assert_equal visibility_checker.message(build_reference), <<~MSG.chomp
          Visibility violation: '::SomeName' belongs to 'components/destination', which is not visible to 'components/source'.
          Is there a different package to use instead, or should 'components/destination' also be visible to 'components/source'?
          
          Inference details: this is a reference to ::SomeName which seems to be defined in some/location.rb.
          To receive help interpreting or resolving this error message, see: https://github.com/Shopify/packwerk/blob/main/TROUBLESHOOT.md#Troubleshooting-violations
        MSG
      end

      private

      sig { returns(Checker) }
      def visibility_checker
        Visibility::Checker.new
      end
    end
  end
end
