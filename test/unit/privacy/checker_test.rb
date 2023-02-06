# typed: true
# frozen_string_literal: true

require 'test_helper'

module Packwerk
  module Privacy
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
        checker = privacy_checker
        reference = build_reference

        refute checker.invalid_reference?(reference)
      end

      test 'ignores if destination package is only enforcing for other constants' do
        destination_package = Packwerk::Package.new(
          name: 'destination_package',
          config: { 'enforce_privacy' => ['::OtherConstant'] }
        )
        checker = privacy_checker
        reference = build_reference(destination_package: destination_package)

        refute checker.invalid_reference?(reference)
      end

      test 'complains about private constant if enforcing privacy for everything' do
        destination_package = Packwerk::Package.new(name: 'destination_package', config: { 'enforce_privacy' => true })
        checker = privacy_checker
        reference = build_reference(destination_package: destination_package)

        assert checker.invalid_reference?(reference)
      end

      test 'complains about private constant if enforcing for specific constants' do
        destination_package = Packwerk::Package.new(name: 'destination_package', config: { 'enforce_privacy' => ['::SomeName'] })
        checker = privacy_checker
        reference = build_reference(destination_package: destination_package)

        assert checker.invalid_reference?(reference)
      end

      test 'complains about nested constant if enforcing for specific constants' do
        destination_package = Packwerk::Package.new(name: 'destination_package', config: { 'enforce_privacy' => ['::SomeName'] })
        checker = privacy_checker
        reference = build_reference(destination_package: destination_package)

        assert checker.invalid_reference?(reference)
      end

      test 'ignores constant that starts like enforced constant' do
        destination_package = Packwerk::Package.new(name: 'destination_package', config: { 'enforce_privacy' => ['::SomeName'] })
        checker = privacy_checker
        reference = build_reference(destination_package: destination_package, constant_name: '::SomeNameButNotQuite')

        refute checker.invalid_reference?(reference)
      end

      test 'ignores public constant even if enforcing privacy for everything' do
        destination_package = Packwerk::Package.new(name: 'destination_package', config: { 'enforce_privacy' => true })
        checker = privacy_checker
        reference = build_reference(destination_package: destination_package, constant_location: 'destination_package/app/public/')

        refute checker.invalid_reference?(reference)
      end

      test 'only checks the package TODO file for private constants' do
        destination_package = Packwerk::Package.new(name: 'destination_package', config: { 'enforce_privacy' => ['::SomeName'] })
        checker = privacy_checker
        reference = build_reference(destination_package: destination_package)

        checker.invalid_reference?(reference)
      end

      test 'provides a useful message' do
        assert_equal privacy_checker.message(build_reference), <<~MSG.chomp
          Privacy violation: '::SomeName' is private to 'components/destination' but referenced from 'components/source'.
          Is there a public entrypoint in 'components/destination/app/public/' that you can use instead?

          Inference details: this is a reference to ::SomeName which seems to be defined in some/location.rb.
          To receive help interpreting or resolving this error message, see: https://github.com/Shopify/packwerk/blob/main/TROUBLESHOOT.md#Troubleshooting-violations
        MSG
      end

      private

      sig { returns(Checker) }
      def privacy_checker
        Privacy::Checker.new
      end
    end
  end
end
