# typed: false
# frozen_string_literal: true

module TestMacro
  def test(description, &)
    method_name = "test_#{description}".gsub(/\W/, '_')
    define_method(method_name, &)
  end

  def setup(&)
    define_method(:setup, &)
  end

  def teardown(&)
    define_method(:teardown, &)
  end
end
