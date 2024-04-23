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
            - package
            - utility
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

      test 'call returns no error if enforce_architecture is unset' do
        write_app_file('packwerk.yml', <<~YML)
          {}
        YML
        result = validator.call(package_set, config)

        assert result.ok?
      end

      test 'call returns an error for invalid enforce_visibility value' do
        merge_into_app_yaml_file('package.yml', { 'enforce_architecture' => 'yes, please.' })

        result = validator.call(package_set, config)

        refute result.ok?
        assert_match(/Invalid 'enforce_architecture' option/, result.error_value)
      end

      test 'call returns success when enforce_architecture is set to strict' do
        merge_into_app_yaml_file('package.yml', { 'enforce_architecture' => 'strict', 'layer' => 'utility' })

        result = validator.call(package_set, config)
        assert result.ok?
      end

      test 'call returns an error for invalid layer value' do
        merge_into_app_yaml_file('package.yml', { 'layer' => 'blah' })

        result = validator.call(package_set, config)

        refute result.ok?
        assert_match(/Invalid 'layer' option in.*?package.yml": "blah". Must be one of \["package", "utility"\]/, result.error_value)
      end

      # We return no error here because it's possible we want to set layers for things so consuming packages can enforce their architecture
      # without the publishing package needing to enforce it.
      test 'call returns no error if a layer is set with enforce_architecture not on' do
        merge_into_app_yaml_file('package.yml', { 'layer' => 'utility' })

        result = validator.call(package_set, config)
        assert result.ok?
      end

      test 'call returns an error if a layer is unset with enforce_architecture on' do
        merge_into_app_yaml_file('package.yml', { 'enforce_architecture' => true })

        result = validator.call(package_set, config)

        refute result.ok?
        assert_match(/Invalid 'layer' option in.*?package.yml": nil. `layer` must be set if `enforce_architecture` is on./, result.error_value)
      end

      test 'call returns an error if enforce_architecture is set without layers specified' do
        write_app_file('packwerk.yml', <<~YML)
          {}
        YML
        merge_into_app_yaml_file('package.yml', { 'enforce_architecture' => true })

        result = validator.call(package_set, config)

        refute result.ok?

        assert_match(/Cannot set 'enforce_architecture' option in.*?package.yml" until `architectural_layers` have been specified in `packwerk.yml`/, result.error_value)
      end

      test 'call returns no error for valid layer value' do
        merge_into_app_yaml_file('package.yml', { 'enforce_architecture' => true, 'layer' => 'utility' })

        result = validator.call(package_set, config)
        assert result.ok?
      end

      test 'call returns no error for no layer value if layer is implied by root location' do
        merge_into_app_yaml_file('utility/package.yml', { 'enforce_architecture' => true })
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
