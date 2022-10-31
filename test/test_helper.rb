# typed: true
# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
ROOT = Pathname.new(__dir__).join('..').expand_path

require 'packwerk-extensions'
require 'packwerk'
require 'minitest/autorun'
require 'mocha/minitest'
require 'support/application_fixture_helper'
require 'support/rails_application_fixture_helper'
require 'support/yaml_file'
require 'support/factory_helper'
require 'support/test_macro'

Minitest::Test.extend(TestMacro)

Mocha.configure do |c|
  c.stubbing_non_existent_method = :prevent
end
