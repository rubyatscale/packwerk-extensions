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

      private

      sig { returns(Checker) }
      def visibility_checker
        Visibility::Checker.new
      end
    end
  end
end
