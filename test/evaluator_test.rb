require 'test/unit'
require '../librpn32768'

class EvaluatorTest < Test::Unit::TestCase

  include RPN32768

  def test_stack_push_integer
    rpn = Evaluator.new
    rpn.eval("32768")
    assert_equal rpn.stack, [32768]
  end

  def test_stack_push_float
    rpn = Evaluator.new
    rpn.eval("3276.8")
    assert_equal rpn.stack, [3276.8]
  end

  def test_operator_addition
    rpn = Evaluator.new
    rpn.eval("1 2 +")
    assert_equal rpn.stack, [3]
  end
end