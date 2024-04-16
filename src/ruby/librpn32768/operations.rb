#
# RPN evaluator
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

#noinspection RubyInterpreter
#noinspection RubyInstanceVariableNamingConvention,RubyClassModuleNamingConvention,RubyLiteralArrayInspection
module RPN32768

  # marker superclass from which all calculator operation classes inherit
  class Operation
  end

  # superclass from which stack operations inherit
  class StackOperation < Operation
    def initialize(stack)
      @s = stack
    end

    private
    attr_reader :s
  end

  # superclass from which secondary stack operations inherit
  class SecondaryStackOperation < StackOperation
    def initialize(stack, secondary)
      super(stack)
      @secondary = secondary
    end

    private
    attr_reader :secondary
  end

  # superclass from which heap operations inherit
  class HeapOperation < StackOperation
    def initialize(stack, heap)
      super(stack)
      @heap = heap
    end

    private

    HEAP_SIZE = 65536

    attr_reader :heap

    class HeapAddressException < OperandOutOfRangeException
      def initialize(msg =
                       "bad heap address (must be int, 0 <= x < #{HEAP_SIZE})")
        super(msg)
      end
    end

    def check_address(a)
      raise HeapAddressException.new \
        if !a.kind_of?(Integer) || (a < 0) || (a >= HEAP_SIZE)
      a
    end
  end


  # one class per calculator operation
  # "names" method returns the names which should invoke the operation
  # "perform" method performs the operation on the supplied stack

  class Depth < StackOperation
    def names
      ['depth', 'size']
    end
    def perform
      s.push(s.size)
    end
  end

  class Plus < StackOperation
    def names
      ['+']
    end
    def perform
      s.push(s.pop + s.pop)
    end
  end

  class Increment < StackOperation
    def names
      ['1+']
    end
    def perform
      s.push(s.pop + 1)
    end
  end

  class Sum < StackOperation
    def names
      ['sum']
    end
    def perform
      sum = 0
      s.pop.to_i.times do
        sum += s.pop
      end
      s.push(sum)
    end
  end

  class SumAll < StackOperation
    def names
      ['sumall']
    end
    def perform
      sum = 0
      sum += s.pop while s.size > 0
      s.push(sum)
    end
  end

  class Minus < StackOperation
    def names
      ['-']
    end
    def perform
      s.push(0 - s.pop + s.pop)
    end
  end

  class Decrement < StackOperation
    def names
      ['1-']
    end
    def perform
      s.push(s.pop - 1)
    end
  end

  class Multiply < StackOperation
    def names
      ['x', '*']
    end
    def perform
      s.push(s.pop * s.pop)
    end
  end

  class Double < StackOperation
    def names
      ['2x', '2*']
    end
    def perform
      s.push(s.pop * 2)
    end
  end

  class Product < StackOperation
    def names
      ['product', 'prod']
    end
    def perform
      product = 1
      s.pop.to_i.times do
        product *= s.pop
      end
      s.push(product)
    end
  end

  class ProductAll < StackOperation
    def names
      ['productall', 'prodall']
    end
    def perform
      prod = 1
      prod *= s.pop while s.size > 0
      s.push(prod)
    end
  end

  class Divide < StackOperation
    def names
      ['/']
    end
    def perform
      divisor = s.pop
      s.push(s.pop / divisor)
    end
  end

  class Modulo < StackOperation
    def names
      ['%', 'mod']
    end
    def perform
      divisor = s.pop
      s.push(s.pop % divisor)
    end
  end

  class Negate < StackOperation
    def names
      ['neg']
    end
    def perform
      s.push(0 - s.pop)
    end
  end

  class AbsoluteValue < StackOperation
    def names
      ['abs']
    end
    def perform
      s.push(s.pop.abs)
    end
  end

  class Reciprocal < StackOperation
    def names
      ['inv']
    end
    def perform
      s.push(1.0 / s.pop)
    end
  end

  class Factorial < StackOperation
    def names
      ['!', 'fact']
    end
    def perform
      s.push(factorial(s.pop))
    end
    private
    def factorial(i)
      if i < 2
        1
      else
        i * factorial(i - 1)
      end
    end
  end

  class Square < StackOperation
    def names
      ['sqr']
    end
    def perform
      s.push(s.pop ** 2)
    end
  end

  class Raise < StackOperation
    def names
      ['**', 'pow', 'raise']
    end
    def perform
      power = s.pop
      s.push(s.pop ** power)
    end
  end

  class SquareRoot < StackOperation
    def names
      ['sqrt']
    end
    def perform
      s.push(Math.sqrt(s.pop))
    rescue Errno::EDOM
      # someone tried to sqrt a negative
      raise OperandOutOfRangeException.new
    end
  end

  class Root < StackOperation
    def names
      ['root']
    end
    def perform
      power = (1.0 / s.pop)
      s.push(s.pop ** power)
    end
  end

  class CommonLogarithm < StackOperation
    def names
      ['log']
    end
    def perform
      s.push(Math.log10(s.pop))
    end
  end

  class NaturalLogarithm < StackOperation
    def names
      ['ln']
    end
    def perform
      s.push(Math.log(s.pop))
    end
  end

  class Euler < StackOperation
    def names
      ['e']
    end
    def perform
      s.push(Math::E)
    end
  end

  class Pi < StackOperation
    def names
      ['pi']
    end
    def perform
      s.push(Math::PI)
    end
  end

  class DegreesToRadians < StackOperation
    def names
      ['dtor']
    end
    def perform
      s.push(s.pop * Math::PI / 180)
    end
  end

  class RadiansToDegrees < StackOperation
    def names
      ['rtod']
    end
    def perform
      s.push(s.pop * 180 / Math::PI)
    end
  end

  class Sine < StackOperation
    def names
      ['sin']
    end
    def perform
      s.push(Math.sin(s.pop))
    end
  end

  class InverseSine < StackOperation
    def names
      ['asin']
    end
    def perform
      s.push(Math.asin(s.pop))
    end
  end

  class Cosine < StackOperation
    def names
      ['cos']
    end
    def perform
      s.push(Math.cos(s.pop))
    end
  end

  class InverseCosine < StackOperation
    def names
      ['acos']
    end
    def perform
      s.push(Math.acos(s.pop))
    end
  end

  class Tangent < StackOperation
    def names
      ['tan']
    end
    def perform
      s.push(Math.tan(s.pop))
    end
  end

  class InverseTangent < StackOperation
    def names
      ['atan']
    end
    def perform
      s.push(Math.atan(s.pop))
    end
  end

  class FahrenheitToCentigrade < StackOperation
    def names
      ['ftoc']
    end
    def perform
      s.push((s.pop - 32) * 5 / 9)
    end
  end

  class CentigradeToFahrenheit < StackOperation
    def names
      ['ctof']
    end
    def perform
      s.push(s.pop * 9 / 5 + 32)
    end
  end

  class BitwiseAnd < StackOperation
    def names
      ['&', 'and']
    end
    def perform
      s.push(s.pop.to_i & s.pop.to_i)
    end
  end

  class BitwiseAndAll < StackOperation
    def names
      ['&all', 'andall']
    end
    def perform
      x = s.pop
      x &= s.pop while s.size > 0
      s.push(x)
    end
  end

  class BitwiseOr < StackOperation
    def names
      ['|', 'or']
    end
    def perform
      s.push(s.pop.to_i | s.pop.to_i)
    end
  end

  class BitwiseOrAll < StackOperation
    def names
      ['|all', 'orall']
    end
    def perform
      x = 0
      x |= s.pop while s.size > 0
      s.push(x)
    end
  end

  class BitwiseXor < StackOperation
    def names
      ['^', 'xor']
    end
    def perform
      s.push(s.pop.to_i ^ s.pop.to_i)
    end
  end

  class BitwiseXorAll < StackOperation
    def names
      ['^all', 'xorall']
    end
    def perform
      x = 0
      x ^= s.pop while s.size > 0
      s.push(x)
    end
  end

  class BitwiseNot < StackOperation
    def names
      ['~', 'not']
    end
    def perform
      s.push(~(s.pop.to_i))
    end
  end

  class ShiftLeft < StackOperation
    def names
      ['<<', 'shl']
    end
    def perform
      places = s.pop
      s.push(s.pop << places)
    end
  end

  class ShiftRight < StackOperation
    def names
      ['>>', 'shr']
    end
    def perform
      places = s.pop
      s.push(s.pop >> places)
    end
  end

  class Duplicate < StackOperation
    def names
      ['dup', 'd']
    end
    def perform
      i = s.pop
      s.push(i).push(i)
    end
  end

  class DuplicateIfNonZero < StackOperation
    def names
      ['?dup', 'nzdup']
    end
    def perform
      val = s.pop
      s.push(val)
      s.push(val) if val.to_f != 0.0
    end
  end

  class Duplicate2 < StackOperation
    def names
      ['2dup']
    end
    def perform
      x = s.pop
      y = s.pop
      s.push(y).push(x).push(y).push(x)
    end
  end

  class Rotate < StackOperation
    def names
      ['rot']
    end
    def perform
      upper = s.pop
      middle = s.pop
      lower = s.pop
      s.push(middle).push(upper).push(lower)
    end
  end

  class RotateBackwards < StackOperation
    def names
      ['-rot']
    end
    def perform
      upper = s.pop
      middle = s.pop
      lower = s.pop
      s.push(upper).push(lower).push(middle)
    end
  end

  class Swap < StackOperation
    def names
      ['s', 'swap']
    end
    def perform
      upper = s.pop
      lower = s.pop
      s.push(upper).push(lower)
    end
  end

  class Swap2 < StackOperation
    def names
      ['2swap']
    end
    def perform
      upper1 = s.pop
      lower1 = s.pop
      upper2 = s.pop
      lower2 = s.pop
      s.push(lower1).push(upper1).push(lower2).push(upper2)
    end
  end

  class Over < StackOperation
    def names
      ['over']
    end
    def perform
      upper = s.pop
      lower = s.pop
      s.push(lower).push(upper).push(lower)
    end
  end

  class Over2 < StackOperation
    def names
      ['2over']
    end
    def perform
      upper1 = s.pop
      lower1 = s.pop
      upper2 = s.pop
      lower2 = s.pop
      s.push(lower2).push(upper2) \
       .push(lower1).push(upper1).push(lower2).push(upper2)
    end
  end

  class Drop < StackOperation
    def names
      ['drop']
    end
    def perform
      s.pop
    end
  end

  class Drop2 < StackOperation
    def names
      ['2drop']
    end
    def perform
      s.pop
      s.pop
    end
  end

  class DropAll < StackOperation
    def names
      ['dropall', 'clear']
    end
    def perform
      s.clear
    end
  end

  class Nip < StackOperation
    def names
      ['nip']
    end
    def perform
      upper = s.pop
      s.pop
      s.push(upper)
    end
  end

  class Tuck < StackOperation
    def names
      ['tuck']
    end
    def perform
      upper = s.pop
      lower = s.pop
      s.push(upper).push(lower).push(upper)
    end
  end

  class ToInteger < StackOperation
    def names
      ['to_i']
    end
    def perform
      s.push(s.pop.to_i)
    end
  end

  class ToReal < StackOperation
    def names
      ['to_f', 'to_r']
    end
    def perform
      s.push(s.pop.to_f)
    end
  end

  class Print < StackOperation
    def names
      ['.']
    end
    def perform
      yield s.pop
    end
  end

  class PrintHex < StackOperation
    def names
      ['.x']
    end
    def perform
      yield "0x#{'%x' % s.pop}"
    end
  end

  class PrintOctal < StackOperation
    def names
      ['.o']
    end
    def perform
      yield "0#{'%o' % s.pop}"
    end
  end

  class PrintBinary < StackOperation
    def names
      ['.b']
    end
    def perform
      yield "0b#{'%b' % s.pop}"
    end
  end

  class DumpStack < StackOperation
    def names
      ['.s']
    end
    def perform
      yield s.join(' ')
    end
  end

  class SecondaryPush < SecondaryStackOperation
    def names
      ['push']
    end
    def perform
      secondary.push(s.pop)
    end
  end

  class SecondaryPop < SecondaryStackOperation
    def names
      ['pop']
    end
    def perform
      s.push(secondary.pop)
    end
  end

  class SecondaryExchange < SecondaryStackOperation
    def names
      ['xchg']
    end
    def perform
      # this implementation is disgusting
      new_secondary = s.dup
      s.clear
      s.concat(secondary)
      secondary.clear
      secondary.concat(new_secondary)
    end
  end

  class Load < HeapOperation
    def names
      ['load']
    end
    def perform
      a = check_address(s.pop)
      s.push(heap.has_key?(a) ? heap[a] : 0)
    end
  end

  class Load0 < HeapOperation
    def names
      ['0load']
    end
    def perform
      s.push(heap.has_key?(0) ? heap[0] : 0)
    end
  end

  class Load1 < HeapOperation
    def names
      ['1load']
    end
    def perform
      s.push(heap.has_key?(1) ? heap[1] : 0)
    end
  end

  class Load2 < HeapOperation
    def names
      ['2load']
    end
    def perform
      s.push(heap.has_key?(2) ? heap[2] : 0)
    end
  end

  class Load3 < HeapOperation
    def names
      ['3load']
    end
    def perform
      s.push(heap.has_key?(3) ? heap[3] : 0)
    end
  end

  class Store < HeapOperation
    def names
      ['store']
    end
    def perform
      a = check_address(s.pop)
      heap[a] = s.pop
    end
  end

  class Store0 < HeapOperation
    def names
      ['0store']
    end
    def perform
      heap[0] = s.pop
    end
  end

  class Store1 < HeapOperation
    def names
      ['1store']
    end
    def perform
      heap[1] = s.pop
    end
  end

  class Store2 < HeapOperation
    def names
      ['2store']
    end
    def perform
      heap[2] = s.pop
    end
  end

  class Store3 < HeapOperation
    def names
      ['3store']
    end
    def perform
      heap[3] = s.pop
    end
  end


  # Aliases consist of a sequence of numbers and operations.  Numbers are
  # #pre-parsed, and are placed directly on the stack.  Operations are
  # performed.
  class Alias < Operation

    def initialize(name, stack, sequence)
      @name = name
      @s = stack
      @sequence = sequence
    end

    def names
      [@name]
    end

    def perform
      sequence.each do |arg|
        if arg.kind_of?(Operation)
          arg.perform do |result|
            yield result
          end
        else
          s.push(arg)
        end
      end
    end

    private
    attr_reader :s, :sequence
  end
end