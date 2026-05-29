# typed: true
# frozen_string_literal: true

require 'test_helper'

module Packwerk
  module Privacy
    class ExtensionWithUnrecognizedConfigTest < Minitest::Test
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
        assert(Packwerk::Checker.all.any?(Packwerk::Privacy::Checker))
      end
    end
  end
end
