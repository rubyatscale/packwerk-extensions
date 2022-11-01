# typed: true
# frozen_string_literal: true

require "test_helper"

module Packwerk
  module Privacy
    class CheckerTest < Minitest::Test
      extend T::Sig
      include FactoryHelper

      test "ignores if destination package is not enforcing" do
        checker = privacy_checker
        reference = build_reference

        refute checker.invalid_reference?(reference)
      end

      test "ignores if destination package is only enforcing for other constants" do
        destination_package = Packwerk::Package.new(
          name: "destination_package",
          config: { "enforce_privacy" => ["::OtherConstant"] }
        )
        checker = privacy_checker
        reference = build_reference(destination_package: destination_package)

        refute checker.invalid_reference?(reference)
      end

      test "complains about private constant if enforcing privacy for everything" do
        destination_package = Packwerk::Package.new(name: "destination_package", config: { "enforce_privacy" => true })
        checker = privacy_checker
        reference = build_reference(destination_package: destination_package)

        assert checker.invalid_reference?(reference)
      end

      test "complains about private constant if enforcing for specific constants" do
        destination_package = Packwerk::Package.new(name: "destination_package", config: { "enforce_privacy" => ["::SomeName"] })
        checker = privacy_checker
        reference = build_reference(destination_package: destination_package)

        assert checker.invalid_reference?(reference)
      end

      test "complains about nested constant if enforcing for specific constants" do
        destination_package = Packwerk::Package.new(name: "destination_package", config: { "enforce_privacy" => ["::SomeName"] })
        checker = privacy_checker
        reference = build_reference(destination_package: destination_package)

        assert checker.invalid_reference?(reference)
      end

      test "ignores constant that starts like enforced constant" do
        destination_package = Packwerk::Package.new(name: "destination_package", config: { "enforce_privacy" => ["::SomeName"] })
        checker = privacy_checker
        reference = build_reference(destination_package: destination_package, constant_name: "::SomeNameButNotQuite")

        refute checker.invalid_reference?(reference)
      end

      test "ignores public constant even if enforcing privacy for everything" do
        destination_package = Packwerk::Package.new(name: "destination_package", config: { "enforce_privacy" => true })
        checker = privacy_checker
        reference = build_reference(destination_package: destination_package, constant_location: 'destination_package/app/public/')

        refute checker.invalid_reference?(reference)
      end

      test "only checks the package TODO file for private constants" do
        destination_package = Packwerk::Package.new(name: "destination_package", config: { "enforce_privacy" => ["::SomeName"] })
        checker = privacy_checker
        reference = build_reference(destination_package: destination_package)

        checker.invalid_reference?(reference)
      end

      private

      sig { returns(Checker) }
      def privacy_checker
        Privacy::Checker.new
      end
    end
  end
end
