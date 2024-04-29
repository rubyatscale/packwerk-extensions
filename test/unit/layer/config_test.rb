# typed: true
# frozen_string_literal: true

require 'test_helper'

module Packwerk
  module Layer
    class ConfigTest < Minitest::Test
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

      def write_architecture_config
        write_app_file('packwerk.yml', <<~YML)
          architecture_layers:
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

      test 'determines correct keys' do
        assert config_instance.layers_key_configured?
        assert_equal config_instance.layers_key, 'layers'
        assert_equal config_instance.violation_key, 'layer'
        assert_equal config_instance.enforce_key, 'enforce_layers'
      end

      test 'finds the layers' do
        assert_equal config_instance.layers_list, %w[orchestrator business_domain]
      end

      test 'determines architecture keys' do
        write_architecture_config
        refute config_instance.layers_key_configured?
        assert_equal config_instance.layers_key, 'architecture_layers'
        assert_equal config_instance.violation_key, 'architecture'
        assert_equal config_instance.enforce_key, 'enforce_architecture'
        assert_equal config_instance.layers_list, %w[orchestrator business_domain]
      end

      private

      sig { returns(Config) }
      def config_instance
        Packwerk::Layer::Config.new
      end
    end
  end
end
