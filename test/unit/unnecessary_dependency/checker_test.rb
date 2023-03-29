# typed: true
# frozen_string_literal: true

require 'test_helper'

module Packwerk
  module UnnecesaryDependency
    class CheckerTest < Minitest::Test
      extend T::Sig
      include FactoryHelper
      include RailsApplicationFixtureHelper

      setup do
        setup_application_fixture
        use_template(:minimal)
      end

      teardown do
        teardown_application_fixture
      end

      test 'writes reference to helper file if it does not exist' do
        checker = Packwerk::UnnecessaryDependency::Checker.new
        reference = build_reference
        refute checker.invalid_reference?(reference)
        assert_equal YAML.load_file('tmp/packwerk/dependencies.yml'), { 'components/source' => ['components/destination'] }
      end

      test 'appends reference to helper file if it does exist' do
        checker = Packwerk::UnnecessaryDependency::Checker.new
        reference = build_reference
        FileUtils.mkdir_p('tmp/packwerk')
        Pathname.new('tmp/packwerk/dependencies.yml').write(
          YAML.dump({ 'components/some_package' => ['components/some_other_package'] })
        )
        refute checker.invalid_reference?(reference)
        references = { 'components/some_package' => ['components/some_other_package'], 'components/source' => ['components/destination'] }
        assert_equal YAML.load_file('tmp/packwerk/dependencies.yml'), references
      end
    end
  end
end
