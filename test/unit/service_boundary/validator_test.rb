# typed: true
# frozen_string_literal: true

require 'test_helper'

# make sure PrivateThing.constantize succeeds to pass the privacy validity check
require 'fixtures/skeleton/components/timeline/app/models/private_thing'

module Packwerk
  module ServiceBoundary
    class ValidatorTest < Minitest::Test
      extend T::Sig
      include ApplicationFixtureHelper
      include RailsApplicationFixtureHelper

      setup do
        setup_application_fixture
      end

      teardown do
        teardown_application_fixture
      end

      # test 'call returns an error for invalid enforce_visibility value' do
      #   use_template(:minimal)
      #   merge_into_app_yaml_file('package.yml', { 'enforce_service_boundary' => 'yes, please.' })

      #   result = validator.call(package_set, config)

      #   refute result.ok?
      #   assert_match(/Invalid 'enforce_service_boundary' option/, result.error_value)
      # end

      test 'call returns success when enforce_service_boundary is set to strict' do
        use_template(:minimal)
        merge_into_app_yaml_file('package.yml', { 'enforce_service_boundary' => 'strict' })

        result = validator.call(package_set, config)

        assert result.ok?
      end

      sig { returns(Packwerk::ServiceBoundary::Validator) }
      def validator
        @validator ||= Packwerk::ServiceBoundary::Validator.new
      end
    end
  end
end
