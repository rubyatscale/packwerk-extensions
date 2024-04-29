# typed: true
# frozen_string_literal: true

require 'test_helper'

module Packwerk
  module Layer
    class ValidatorTest < Minitest::Test
      extend T::Sig
      include ApplicationFixtureHelper
      include RailsApplicationFixtureHelper

      def write_config
        write_app_file('packwerk.yml', <<~YML)
          layers:
            - package
            - utility
        YML
      end

      def write_architecture_config
        write_config
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

      test 'call returns no error if enforce_layers is unset' do
        write_app_file('packwerk.yml', <<~YML)
          {}
        YML
        result = validator.call(package_set, config)

        assert result.ok?
      end

      test 'call returns an error for invalid enforce_layers value' do
        merge_into_app_yaml_file('package.yml', { 'enforce_layers' => 'yes, please.' })

        result = validator.call(package_set, config)

        refute result.ok?
        assert_match(/Invalid 'enforce_layers' option/, result.error_value)
      end

      test 'call returns an error for invalid enforce_architecture value' do
        write_architecture_config

        merge_into_app_yaml_file('package.yml', { 'enforce_architecture' => 'yes, please.' })

        result = validator.call(package_set, config)

        refute result.ok?
        assert_match(/Invalid 'enforce_architecture' option/, result.error_value)
      end

      test 'call returns success when enforce_layers is set to strict' do
        merge_into_app_yaml_file('package.yml', { 'enforce_layers' => 'strict', 'layer' => 'utility' })

        result = validator.call(package_set, config)
        assert result.ok?
      end

      test 'call returns success when enforce_architecture is set to strict' do
        write_architecture_config

        merge_into_app_yaml_file('package.yml', { 'enforce_architecture' => 'strict', 'layer' => 'utility' })

        result = validator.call(package_set, config)
        assert result.ok?
      end

      test 'call returns error when enforce_layers is set to strict, but enforce_architecture is required' do
        write_architecture_config

        merge_into_app_yaml_file('package.yml', { 'enforce_layers' => 'strict', 'layer' => 'utility' })

        result = validator.call(package_set, config)
        refute result.ok?

        assert_match(/Unexpected `enforce_layers` option in/, result.error_value)
      end

      test 'call returns error when enforce_architecture is set to strict, but enforce_layers is required' do
        merge_into_app_yaml_file('package.yml', { 'enforce_architecture' => 'strict', 'layer' => 'utility' })

        result = validator.call(package_set, config)
        refute result.ok?

        assert_match(/Unexpected `enforce_architecture` option in/, result.error_value)
      end

      test 'call returns an error for invalid layer value' do
        merge_into_app_yaml_file('package.yml', { 'layer' => 'blah' })

        result = validator.call(package_set, config)

        refute result.ok?
        assert_match(/Invalid 'layer' option in.*?package.yml": "blah". Must be one of \["package", "utility"\]/, result.error_value)
      end

      # We return no error here because it's possible we want to set layers for things so consuming packages can enforce their layer
      # without the publishing package needing to enforce it.
      test 'call returns no error if a layer is set with enforce_layers not on' do
        merge_into_app_yaml_file('package.yml', { 'layer' => 'utility' })

        result = validator.call(package_set, config)
        assert result.ok?
      end

      test 'call returns an error if a layer is unset with enforce_layers on' do
        merge_into_app_yaml_file('package.yml', { 'enforce_layers' => true })

        result = validator.call(package_set, config)

        refute result.ok?
        assert_match(/Invalid 'layer' option in.*?package.yml": nil. `layer` must be set if `enforce_layers` is on./, result.error_value)
      end

      test 'call returns an error if a layer is unset with enforce_architecture on' do
        write_architecture_config

        merge_into_app_yaml_file('package.yml', { 'enforce_architecture' => true })

        result = validator.call(package_set, config)

        refute result.ok?
        assert_match(/Invalid 'layer' option in.*?package.yml": nil. `layer` must be set if `enforce_architecture` is on./, result.error_value)
      end

      test 'call returns an error if enforce_layers is set without layers specified' do
        write_app_file('packwerk.yml', <<~YML)
          {}
        YML
        merge_into_app_yaml_file('package.yml', { 'enforce_layers' => true })

        result = validator.call(package_set, config)

        refute result.ok?

        assert_match(/Cannot set 'enforce_layers' option in.*?package.yml" until `layers` have been specified in `packwerk.yml`/, result.error_value)
      end

      test 'call returns no error for valid layer value' do
        merge_into_app_yaml_file('package.yml', { 'enforce_layers' => true, 'layer' => 'utility' })

        result = validator.call(package_set, config)
        assert result.ok?
      end

      test 'call returns no error for no layer value if layer is implied by root location' do
        merge_into_app_yaml_file('utility/package.yml', { 'enforce_layers' => true })
        result = validator.call(package_set, config)
        assert result.ok?
      end

      test 'call permitted keys' do 
        assert_equal validator.permitted_keys, ['enforce_layers', 'layer']
      end

      test 'call permitted keys when architecture' do 
        write_architecture_config
        assert_equal validator.permitted_keys, ['enforce_architecture', 'layer']
      end

      sig { returns(Packwerk::Layer::Validator) }
      def validator
        @validator ||= Packwerk::Layer::Validator.new
      end
    end
  end
end
