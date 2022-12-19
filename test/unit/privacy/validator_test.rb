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

    test 'check_all returns an error for invalid enforce_privacy value' do
      use_template(:minimal)
      merge_into_app_yaml_file('package.yml', { 'enforce_privacy' => 'yes, please.' })

      result = Packwerk::Privacy::Validator.new.call(package_set, config)

      refute result.ok?
      assert_match(/Invalid 'enforce_privacy' option/, result.error_value)
    end

    test 'check_all returns success for when enforce_privacy is set to strict' do
      use_template(:minimal)
      merge_into_app_yaml_file('package.yml', { 'enforce_privacy' => 'strict' })

      result = Packwerk::Privacy::Validator.new.call(package_set, config)

      assert result.ok?
    end

    test 'check_all returns an error for invalid public_path value' do
      use_template(:minimal)
      merge_into_app_yaml_file('package.yml', { 'public_path' => [] })

      result = Packwerk::Privacy::Validator.new.call(package_set, config)

      refute result.ok?
      assert_match(/'public_path' option must be a string/, result.error_value)
    end

    sig { returns(Packwerk::ApplicationValidator) }
    def validator
      @validator ||= Packwerk::ApplicationValidator.new
    end
  end
end
