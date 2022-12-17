# typed: true
# frozen_string_literal: true

require 'test_helper'

module Packwerk
  module Architecture
    class ValidatorTest < Minitest::Test
      extend T::Sig
      include ApplicationFixtureHelper
      include RailsApplicationFixtureHelper

      def write_config
        write_app_file('packwerk.yml', <<~YML)
          architecture_layers:
            - business_domain
            - platform
        YML
      end

      setup do
        setup_application_fixture
        use_template(:minimal)
        write_config
      end

      teardown do
        teardown_application_fixture
      end

      test 'call returns an error for invalid enforce_visibility value' do
        merge_into_app_yaml_file('package.yml', { 'enforce_architecture' => 'yes, please.' })

        result = validator.call(package_set, config)

        refute result.ok?
        assert_match(/Invalid 'enforce_architecture' option/, result.error_value)
      end

      test 'call returns success when enforce_architecture is set to strict' do
        merge_into_app_yaml_file('package.yml', { 'enforce_architecture' => 'strict' })

        result = validator.call(package_set, config)

        assert result.ok?
      end

      # test 'call returns an error for invalid layer value' do
      #   merge_into_app_yaml_file('package.yml', { 'layer' => 'blah' })

      #   result = validator.call(package_set, config)

      #   refute result.ok?
      #   assert_match(/'layer' option must be one of ["business_domain", "platform"]/, result.error_value)
      # end

      # TODO: Validate that if something enforces architecture, it has a layer
      # Validate that layer is in the list of possible layers
      # Validate that dependencies never violate layers
      # Validate that if anything uses enforce_architecture, then architecture_layers are set 

      test 'call returns no error for valid layer value' do
        merge_into_app_yaml_file('package.yml', { 'layer' => 'platform' })

        result = validator.call(package_set, config)

        assert result.ok?
      end

      sig { returns(Packwerk::Architecture::Validator) }
      def validator
        @validator ||= Packwerk::Architecture::Validator.new
      end
    end
  end
end
