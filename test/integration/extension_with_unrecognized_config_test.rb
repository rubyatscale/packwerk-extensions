# typed: true
# frozen_string_literal: true

require 'test_helper'

module Packwerk
  module Privacy
    class ExtensionWithUnrecognizedConfigTest < Minitest::Test
      extend T::Sig

      include ApplicationFixtureHelper

      setup do
        setup_application_fixture
      end

      teardown do
        teardown_application_fixture
      end

      test 'extension is properly loaded' do
        use_template(:with_unrecognized_config)
        Packwerk::Checker.all
        assert_equal(Packwerk::Checker.all.count, 5)
        found_checker = Packwerk::Checker.all.any? do |checker|
          T.unsafe(checker).is_a?(Packwerk::Privacy::Checker)
        end
        assert found_checker
      end
    end
  end
end
