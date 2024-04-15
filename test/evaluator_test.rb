#
# Tests for RPN evaluator
#
# Copyright (c) 2007-2024 Stephen Williams
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

require 'test/unit'
require_relative '../librpn32768'

class EvaluatorTest < Test::Unit::TestCase

  include RPN32768

  def test_stack_push_integer
    rpn = Evaluator.new
    rpn.eval("32768")
    assert_equal [32768], rpn.stack
  end

  def test_stack_push_float
    rpn = Evaluator.new
    rpn.eval("3276.8")
    assert_equal [3276.8], rpn.stack
  end

  def test_stack_exchange
    rpn = Evaluator.new
    rpn.eval("32768 xchg")
    assert_equal [], rpn.stack
    assert_equal [32768], rpn.secondary_stack
  end

  def test_heap_store_load
    rpn = Evaluator.new
    rpn.eval("32768 0store 47 0load")
    assert_equal  [47, 32768], rpn.stack
  end

  def test_stack_is_returned
    rpn = Evaluator.new
    assert_equal [1, 2, 3], rpn.eval("1 2 3")
  end

  def test_alias
    rpn = Evaluator.new
    rpn.eval("def tau 2 pi * end")
    rpn.eval("tau")
    assert_equal  [2 * Math::PI], rpn.stack
  end

  def test_print_binary
    rpn = Evaluator.new
    rpn.eval("3 .b") do |result|
      assert_equal "0b11", result
    end
  end

  def test_operator_addition
    rpn = Evaluator.new
    rpn.eval("1 2 +")
    assert_equal [3], rpn.stack
  end

  def test_help
    rpn = Evaluator.new
    output = []
    rpn.eval("help") do |result|
      output << result
    end
    assert_not_empty output.filter{|s| s.match(/^sumall\s+Adds all the numbers on the stack$/)}
  end

  def test_help_op
    rpn = Evaluator.new
    output = []
    rpn.eval("help x") do |result|
      output << result
    end
    assert_equal ["Operator: *",
                  "Synonyms: x, *",
                  "Multiplies two numbers",
                  "",
                  "Pops two numbers from the stack, multiplies them, and pushes the result back",
                  "on the stack.",
                  "Example: 3 2 *",
                  "Result: 6"], output
  end
end