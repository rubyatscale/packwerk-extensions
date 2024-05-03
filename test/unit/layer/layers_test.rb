# typed: true
# frozen_string_literal: true

require 'test_helper'

module Packwerk
  module Layer
    class LayersTest < Minitest::Test
      extend T::Sig
      include FactoryHelper
      include RailsApplicationFixtureHelper

      def write_config
        write_app_file('packwerk.yml', <<~YML)
          layers:
            - orchestrator
            - business_domain
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

      test 'finds the configured layers' do
        assert_equal layers_class.names, Set.new(%w[orchestrator business_domain])
      end

      private

      sig { returns(Layers) }
      def layers_class
        Packwerk::Layer::Layers.new
      end
    end
  end
end
