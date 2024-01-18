# typed: false
# frozen_string_literal: true

require 'test_helper'

module Packwerk
  module ServiceBoundary
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

      true_ = true

      [
        # enforce, pack,             referencing pack  invalid?   note
        [false, 'packs/a',         'packs/b/c/d/e/f', false, 'turned off'],
        [true_, 'packs/a',         'packs/b',         false, 'siblings are ok'],
        [true_, 'packs/a',         'packs/c',         false, 'siblings are ok'],
        [true_, 'packs/a/packs/1', 'packs/a/packs/2', false, 'siblings are ok'],
        [true_, 'packs/a/packs/1', 'packs/a/packs',   false, 'access from parent is ok'],
        [true_, 'packs/a/packs/1', 'packs/a',         false, 'access from parent of parent is ok'],
        [true_, 'packs/a/packs/1', 'packs',           false, 'access from parent of parent is ok'],
        [true_, 'packs/a/packs/1', '.',               false, 'access from root pack is ok'],

        [true_, 'packs/a',         'packs/b/c',       true_, 'not siblings or child'],
        [true_, 'packs/a',         'packs/b/packs/c', true_, 'not siblings or child'],
        [true_, 'packs/a/packs/1', 'packs/b/packs/1', true_, 'not siblings or child'],
        [true_, 'packs/a',         'packs/a/packs/1', true_, 'access to parent not ok'],
        [true_, 'packs/b',         'packs/a/packs/1', true_, 'not siblings or child']
      ].each do |test|
        test "if #{test[1]} has enforce_service_boundary: #{test[0]} than a reference from #{test[2]} is #{test[3] ? 'A VIOLATION' : 'OK'}" do
          source_package = Packwerk::Package.new(name: test[2])
          destination_package = Packwerk::Package.new(name: test[1], config: { 'enforce_service_boundary' => test[0] })
          reference = build_reference(
            source_package: source_package,
            destination_package: destination_package
          )

          assert_equal test[3], service_boundary_checker.invalid_reference?(reference)
        end
      end

      test 'provides a useful message' do
        assert_equal service_boundary_checker.message(build_reference), <<~MSG.chomp
          Service Boundary violation: '::SomeName' belongs to 'components/destination', which is in a different product service to 'components/source'.
          Please reach out to the owners of that product service to find out if there should be a product service API for this code.
          
          Inference details: this is a reference to ::SomeName which seems to be defined in some/location.rb.
          To receive help interpreting or resolving this error message, see: https://github.com/Shopify/packwerk/blob/main/TROUBLESHOOT.md#Troubleshooting-violations
        MSG
      end

      private

      sig { returns(Checker) }
      def service_boundary_checker
        ServiceBoundary::Checker.new
      end
    end
  end
end
