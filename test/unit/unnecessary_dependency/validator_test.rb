# typed: true
# frozen_string_literal: true

require 'test_helper'

module Packwerk
  module UnnecesaryDependency
    class ValidatorTest < Minitest::Test
      extend T::Sig
      include ApplicationFixtureHelper
      include RailsApplicationFixtureHelper

      setup do
        setup_application_fixture
        use_template(:minimal)
      end

      teardown do
        teardown_application_fixture
      end

      test 'call returns no error when tmp/packwerk/dependencies.yml does not exist' do
        merge_into_app_yaml_file('package.yml', { 'dependencies' => ['blah'] })

        result = validator.call(package_set, config)

        assert result.ok?
      end

      test 'call returns no error when package has only necessary dependencies' do
        merge_into_app_yaml_file('package.yml', { 'dependencies' => ['blah'] })
        FileUtils.mkdir_p('tmp/packwerk')
        Pathname.new('tmp/packwerk/dependencies.yml').write(YAML.dump({ '.' => ['blah'] }))
        result = validator.call(package_set, config)

        assert result.ok?
      end

      test 'call returns an error when package has unnecessary dependencies' do
        merge_into_app_yaml_file('package.yml', { 'dependencies' => %w[blah whoops] })
        FileUtils.mkdir_p('tmp/packwerk')
        Pathname.new('tmp/packwerk/dependencies.yml').write(YAML.dump({ '.' => ['blah'] }))
        result = validator.call(package_set, config)

        refute result.ok?
        assert_match(/Invalid 'dependencies' in package.yml. 'package.yml' has unnecessary dependencies \["whoops"\]/, result.error_value)
      end

      sig { returns(Packwerk::UnnecessaryDependency::Validator) }
      def validator
        @validator ||= Packwerk::UnnecessaryDependency::Validator.new
      end
    end
  end
end
