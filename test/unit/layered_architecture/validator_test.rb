# typed: true
# frozen_string_literal: true

require 'test_helper'

module Packwerk
  module LayeredArchitecture
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
        write_config
      end

      teardown do
        teardown_application_fixture
      end

      test 'call returns an error for invalid enforce_visibility value' do
        use_template(:minimal)
        merge_into_app_yaml_file('package.yml', { 'enforce_layered_architecture' => 'yes, please.' })

        result = validator.call(package_set, config)

        refute result.ok?
        assert_match(/Invalid 'enforce_layered_architecture' option/, result.error_value)
      end

      test 'call returns success when enforce_layered_architecture is set to strict' do
        use_template(:minimal)
        merge_into_app_yaml_file('package.yml', { 'enforce_layered_architecture' => 'strict' })

        result = validator.call(package_set, config)

        assert result.ok?
      end

      test 'call returns an error for invalid layer value' do
        use_template(:minimal)
        merge_into_app_yaml_file('package.yml', { 'layer' => 'blah' })

        result = validator.call(package_set, config)

        refute result.ok?
        assert_match(/'layer' option must be one of ["business_domain", "platform"]/, result.error_value)
      end

      test 'call returns no error for valid layer value' do
        use_template(:minimal)
        merge_into_app_yaml_file('package.yml', { 'layer' => 'platform' })

        result = validator.call(package_set, config)

        assert result.ok?
      end

      sig { returns(Packwerk::LayeredArchitecture::Validator) }
      def validator
        @validator ||= Packwerk::LayeredArchitecture::Validator.new
      end
    end
  end
end
