# typed: true
# frozen_string_literal: true

require 'test_helper'

module Packwerk
  module Privacy
    class PackageTest < Minitest::Test
      extend T::Sig

      include RailsApplicationFixtureHelper

      setup do
        setup_application_fixture
        @package = Packwerk::Package.new(name: 'components/timeline', config: { 'enforce_privacy' => true, 'private_constants' => ['::Test'] })
      end

      teardown do
        teardown_application_fixture
      end

      sig { returns(Package) }
      def privacy_package
        Package.from(@package)
      end

      test '#enforce_privacy returns same value as from config' do
        assert_equal(true, privacy_package.enforce_privacy)
      end

      test '#public_path returns expected path when using the default public path' do
        assert_equal('components/timeline/app/public/', privacy_package.public_path)
      end

      test '#public_path returns expected path when using a user defined public path' do
        @package = Packwerk::Package.new(name: 'components/timeline', config: { 'public_path' => ['my/path'] })
        assert_equal('components/timeline/my/path/', privacy_package.public_path)
      end

      test '#public_path returns expected path when using the default public path in root package' do
        @package = Packwerk::Package.new(name: '.', config: {})
        assert_equal('app/public/', privacy_package.public_path)
      end

      test '#public_path returns expected path when using a user defined public path' do
        @package = Packwerk::Package.new(name: '.', config: { 'public_path' => 'my/path/' })

        assert_equal('my/path/', privacy_package.public_path)
      end

      test "#public_path? returns true for path under the root package's public path" do
        @package = Packwerk::Package.new(name: '.', config: {})
        assert_equal(true, privacy_package.public_path?('app/public/entrypoint.rb'))
      end

      test "#public_path? returns false for path not under the root package's public path" do
        @package = Packwerk::Package.new(name: '.', config: {})
        assert_equal(false, privacy_package.public_path?('app/models/something.rb'))
      end

      test '#user_defined_public_path returns the same value as in the config when set' do
        @package = Packwerk::Package.new(name: 'components/timeline', config: { 'public_path' => 'my/path/' })
        assert_equal('my/path/', privacy_package.user_defined_public_path)
      end

      test '#user_defined_public_path adds a trailing forward slash to the path if it does not exist' do
        @package = Packwerk::Package.new(name: 'components/timeline', config: { 'public_path' => 'my/path' })
        assert_equal('my/path/', privacy_package.user_defined_public_path)
      end

      test "#public_path? returns true for path under the package's public path" do
        assert_equal(true, privacy_package.public_path?('components/timeline/app/public/entrypoint.rb'))
      end

      test "#public_path? returns false for path not under the package's public path" do
        assert_equal(false, privacy_package.public_path?('components/timeline/app/models/something.rb'))
      end

      test '#user_defined_public_path returns nil when not set in the configuration' do
        assert_nil(privacy_package.user_defined_public_path)
      end
    end
  end
end
