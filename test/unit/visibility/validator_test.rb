# typed: true
# frozen_string_literal: true

require 'test_helper'

# make sure PrivateThing.constantize succeeds to pass the privacy validity check
require 'fixtures/skeleton/components/timeline/app/models/private_thing'

module Packwerk
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

    test 'call returns an error for invalid enforce_visibility value' do
      use_template(:minimal)
      merge_into_app_yaml_file('package.yml', { 'enforce_visibility' => 'yes, please.' })

      result = validator.call(package_set, config)

      refute result.ok?
      assert_match(/Invalid 'enforce_visibility' option/, result.error_value)
    end

    test 'call returns an error for invalid visible_to value' do
      use_template(:minimal)
      merge_into_app_yaml_file('package.yml', { 'visible_to' => 'blah' })

      result = validator.call(package_set, config)

      refute result.ok?
      assert_match(/'visible_to' option must be an array/, result.error_value)
    end

    test 'call returns an error for invalid packages in visible_to' do
      use_template(:minimal)
      merge_into_app_yaml_file('package.yml', { 'visible_to' => ['blah'] })

      result = validator.call(package_set, config)

      refute result.ok?
      assert_match(/'visible_to' option must only contain valid packages in.*?package.yml". Invalid packages: \["blah"\]/, result.error_value)
    end

    test 'call returns no errors for valid visible_to values' do
      use_template(:minimal)
      merge_into_app_yaml_file('package.yml', { 'visible_to' => ['.'] })

      result = validator.call(package_set, config)

      assert result.ok?
    end

    sig { returns(Packwerk::Visibility::Validator) }
    def validator
      @validator ||= Packwerk::Visibility::Validator.new
    end
  end
end
