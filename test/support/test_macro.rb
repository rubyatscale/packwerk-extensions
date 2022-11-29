# typed: false
# frozen_string_literal: true

module TestMacro
  def test(description, &block)
    method_name = "test_#{description}".gsub(/\W/, '_')
    define_method(method_name, &block)
  end

  def setup(&block)
    define_method(:setup, &block)
  end

  def teardown(&block)
    define_method(:teardown, &block)
  end
end
