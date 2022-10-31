# typed: true
# frozen_string_literal: true

require 'test_helper'

module Packwerk
  module Privacy
    class ExtensionTest < Minitest::Test
      extend T::Sig

      include ApplicationFixtureHelper

      setup do
        setup_application_fixture
      end

      teardown do
        teardown_application_fixture
      end

      test 'extension is properly loaded' do
        use_template(:extended)
        Packwerk::Checker.all
        assert_equal(Packwerk::Checker.all.count, 1)
        assert T.unsafe(Packwerk::Checker.all.first).is_a?(Packwerk::Privacy::Checker)
      end
    end
  end
end
