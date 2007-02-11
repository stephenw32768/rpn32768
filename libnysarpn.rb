#
# RPN evaluator
#
# Copyright (c) 2007 Stephen Williams, all rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. The name of the copyright holder may not be used to endorse or
#    promote products derived from this software without specific prior
#    written permission.
#
# THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

module NysaRPN

  RCSID = "$Id: libnysarpn.rb,v 1.3 2007/02/10 22:14:50 stephen Exp stephen $"


  # marker superclass from which all calculator operation classes inherit
  class Operation
  end

  # marker superclass from which all builtin operation classes inherit
  class BuiltinOperation < Operation
  end

  # superclass from which secondary stack operations inherit
  class SecondaryStackOperation < BuiltinOperation
    def initialize(s)
      @secondary = s
    end

    private
    attr_reader :secondary
  end

  # superclass from which register operations inherit
  class RegisterOperation < BuiltinOperation
    def initialize(r)
      @registers = r
    end

    private
    attr_reader :registers
  end


  # one class per calculator operation
  # "names" method returns the names which should invoke the operation
  # "perform" method performs the operation on the supplied stack

  class Depth < BuiltinOperation
    def names
      ['depth', 'size']
    end
    def perform(s)
      s.push(s.size)
    end
  end

  class Plus < BuiltinOperation
    def names
      ['+']
    end
    def perform(s)
      s.push(s.pop + s.pop)
    end
  end

  class Increment < BuiltinOperation
    def names
      ['1+']
    end
    def perform(s)
      s.push(s.pop + 1)
    end
  end

  class Sum < BuiltinOperation
    def names
      ['sum']
    end
    def perform(s)
      sum = 0
      s.pop.to_i.times do
        sum += s.pop
      end
      s.push(sum)
    end
  end

  class SumAll < BuiltinOperation
    def names
      ['sumall']
    end
    def perform(s)
      sum = 0
      sum += s.pop while s.size > 0
      s.push(sum)
    end
  end

  class Minus < BuiltinOperation
    def names
      ['-']
    end
    def perform(s)
      s.push(0 - s.pop + s.pop)
    end
  end

  class Decrement < BuiltinOperation
    def names
      ['1-']
    end
    def perform(s)
      s.push(s.pop - 1)
    end
  end

  class Multiply < BuiltinOperation
    def names
      ['x', '*']
    end
    def perform(s)
      s.push(s.pop * s.pop)
    end
  end

  class Double < BuiltinOperation
    def names
      ['2x', '2*']
    end
    def perform(s)
      s.push(s.pop * 2)
    end
  end

  class Product < BuiltinOperation
    def names
      ['product', 'prod']
    end
    def perform(s)
      product = 1
      s.pop.to_i.times do
        product *= s.pop
      end
      s.push(product)
    end
  end

  class ProductAll < BuiltinOperation
    def names
      ['productall', 'prodall']
    end
    def perform(s)
      prod = 1
      prod *= s.pop while s.size > 0
      s.push(prod)
    end
  end

  class Divide < BuiltinOperation
    def names
      ['/']
    end
    def perform(s)
      divisor = s.pop
      s.push(s.pop / divisor)
    end
  end

  class Modulo < BuiltinOperation
    def names
      ['%', 'mod']
    end
    def perform(s)
      divisor = s.pop
      s.push(s.pop % divisor)
    end
  end

  class Negate < BuiltinOperation
    def names
      ['neg']
    end
    def perform(s)
      s.push(0 - s.pop)
    end
  end

  class Modulus < BuiltinOperation
    def names
      ['abs']
    end
    def perform(s)
      s.push(s.pop.abs)
    end
  end

  class Reciprocal < BuiltinOperation
    def names
      ['inv']
    end
    def perform(s)
      s.push(1.0 / s.pop)
    end
  end

  class Factorial < BuiltinOperation
    def names
      ['!']
    end
    def perform(s)
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

  class Square < BuiltinOperation
    def names
      ['sqr']
    end
    def perform(s)
      s.push(s.pop ** 2)
    end
  end

  class Raise < BuiltinOperation
    def names
      ['**', 'pow', 'raise']
    end
    def perform(s)
      power = s.pop
      s.push(s.pop ** power)
    end
  end

  class SquareRoot < BuiltinOperation
    def names
      ['sqrt']
    end
    def perform(s)
      s.push(Math.sqrt(s.pop))
    end
  end

  class Root < BuiltinOperation
    def names
      ['root']
    end
    def perform(s)
      power = (1.0 / s.pop)
      s.push(s.pop ** power)
    end
  end

  class CommonLogarithm < BuiltinOperation
    def names
      ['log']
    end
    def perform(s)
      s.push(Math.log10(s.pop))
    end
  end

  class NaturalLogarithm < BuiltinOperation
    def names
      ['ln']
    end
    def perform(s)
      s.push(Math.log(s.pop))
    end
  end

  class Euler < BuiltinOperation
    def names
      ['e']
    end
    def perform(s)
      s.push(Math::E)
    end
  end

  class Pi < BuiltinOperation
    def names
      ['pi']
    end
    def perform(s)
      s.push(Math::PI)
    end
  end

  class DegreesToRadians < BuiltinOperation
    def names
      ['dtor']
    end
    def perform(s)
      s.push(s.pop * Math::PI / 180)
    end
  end

  class RadiansToDegrees < BuiltinOperation
    def names
      ['rtod']
    end
    def perform(s)
      s.push(s.pop * 180 / Math::PI)
    end
  end

  class Sine < BuiltinOperation
    def names
      ['sin']
    end
    def perform(s)
      s.push(Math.sin(s.pop))
    end
  end

  class InverseSine < BuiltinOperation
    def names
      ['asin']
    end
    def perform(s)
      s.push(Math.asin(s.pop))
    end
  end

  class Cosine < BuiltinOperation
    def names
      ['cos']
    end
    def perform(s)
      s.push(Math.cos(s.pop))
    end
  end

  class InverseCosine < BuiltinOperation
    def names
      ['acos']
    end
    def perform(s)
      s.push(Math.acos(s.pop))
    end
  end

  class Tangent < BuiltinOperation
    def names
      ['tan']
    end
    def perform(s)
      s.push(Math.tan(s.pop))
    end
  end

  class InverseTangent < BuiltinOperation
    def names
      ['atan']
    end
    def perform(s)
      s.push(Math.atan(s.pop))
    end
  end

  class FahrenheitToCentigrade < BuiltinOperation
    def names
      ['ftoc']
    end
    def perform(s)
      s.push((s.pop - 32) * 5 / 9)
    end
  end

  class CentigradeToFahrenheit < BuiltinOperation
    def names
      ['ctof']
    end
    def perform(s)
      s.push(s.pop * 9 / 5 + 32)
    end
  end

  class BitwiseAnd < BuiltinOperation
    def names
      ['&', 'and']
    end
    def perform(s)
      s.push(s.pop.to_i & s.pop.to_i)
    end
  end

  class BitwiseOr < BuiltinOperation
    def names
      ['|', 'or']
    end
    def perform(s)
      s.push(s.pop.to_i | s.pop.to_i)
    end
  end

  class BitwiseXor < BuiltinOperation
    def names
      ['^', 'xor']
    end
    def perform(s)
      s.push(s.pop.to_i ^ s.pop.to_i)
    end
  end

  class BitwiseNot < BuiltinOperation
    def names
      ['~', 'not']
    end
    def perform(s)
      s.push(~(s.pop.to_i))
    end
  end

  class ShiftLeft < BuiltinOperation
    def names
      ['<<', 'shl']
    end
    def perform(s)
      places = s.pop
      s.push(s.pop << places)
    end
  end

  class ShiftRight < BuiltinOperation
    def names
      ['>>', 'shr']
    end
    def perform(s)
      places = s.pop
      s.push(s.pop >> places)
    end
  end

  class Duplicate < BuiltinOperation
    def names
      ['dup', 'd']
    end
    def perform(s)
      i = s.pop
      s.push(i).push(i)
    end
  end

  class DuplicateIfNonZero < BuiltinOperation
    def names
      ['?dup', 'nzdup']
    end
    def perform(s)
      val = s.pop
      s.push(val)
      s.push(val) if val.to_f != 0.0
    end
  end

  class Duplicate2 < BuiltinOperation
    def names
      ['2dup']
    end
    def perform(s)
      x = s.pop
      y = s.pop
      s.push(y).push(x).push(y).push(x)
    end
  end

  class Rotate < BuiltinOperation
    def names
      ['rot']
    end
    def perform(s)
      upper = s.pop
      middle = s.pop
      lower = s.pop
      s.push(middle).push(upper).push(lower)
    end
  end

  class RotateBackwards < BuiltinOperation
    def names
      ['-rot']
    end
    def perform(s)
      upper = s.pop
      middle = s.pop
      lower = s.pop
      s.push(upper).push(lower).push(middle)
    end
  end

  class Swap < BuiltinOperation
    def names
      ['s', 'swap']
    end
    def perform(s)
      upper = s.pop
      lower = s.pop
      s.push(upper).push(lower)
    end
  end

  class Swap2 < BuiltinOperation
    def names
      ['2swap']
    end
    def perform(s)
      upper1 = s.pop
      lower1 = s.pop
      upper2 = s.pop
      lower2 = s.pop
      s.push(lower1).push(upper1).push(lower2).push(upper2)
    end
  end

  class Over < BuiltinOperation
    def names
      ['over']
    end
    def perform(s)
      upper = s.pop
      lower = s.pop
      s.push(lower).push(upper).push(lower)
    end
  end

  class Over2 < BuiltinOperation
    def names
      ['2over']
    end
    def perform(s)
      upper1 = s.pop
      lower1 = s.pop
      upper2 = s.pop
      lower2 = s.pop
      s.push(lower2).push(upper2) \
        .push(lower1).push(upper1).push(lower2).push(upper2)
    end
  end

  class Drop < BuiltinOperation
    def names
      ['drop']
    end
    def perform(s)
      s.pop
    end
  end

  class Drop2 < BuiltinOperation
    def names
      ['2drop']
    end
    def perform(s)
      s.pop
      s.pop
    end
  end

  class DropAll < BuiltinOperation
    def names
      ['dropall', 'clear']
    end
    def perform(s)
      s.clear
    end
  end

  class Nip < BuiltinOperation
    def names
      ['nip']
    end
    def perform(s)
      upper = s.pop
      s.pop
      s.push(upper)
    end
  end

  class Tuck < BuiltinOperation
    def names
      ['tuck']
    end
    def perform(s)
      upper = s.pop
      lower = s.pop
      s.push(upper).push(lower).push(upper)
    end
  end

  class ToInteger < BuiltinOperation
    def names
      ['to_i']
    end
    def perform(s)
      s.push(s.pop.to_i)
    end
  end

  class ToReal < BuiltinOperation
    def names
      ['to_f', 'to_r']
    end
    def perform(s)
      s.push(s.pop.to_f)
    end
  end

  class Print < BuiltinOperation
    def names
      ['.']
    end
    def perform(s)
      yield s.pop
    end
  end

  class PrintHex < BuiltinOperation
    def names
      ['.x']
    end
    def perform(s)
      yield "0x#{'%x' % s.pop}"
    end
  end

  class PrintOctal < BuiltinOperation
    def names
      ['.o']
    end
    def perform(s)
      yield "0#{'%o' % s.pop}"
    end
  end

  class PrintBinary < BuiltinOperation
    def names
      ['.b']
    end
    def perform(s)
      yield "0b#{'%b' % s.pop}"
    end
  end

  class DumpStack < BuiltinOperation
    def names
      ['.s']
    end
    def perform(s)
      yield s.join(' ')
    end
  end

  class SecondaryPush < SecondaryStackOperation
    def names
      ['push']
    end
    def perform(s)
      secondary.push(s.pop)
    end
  end

  class SecondaryPop < SecondaryStackOperation
    def names
      ['pop']
    end
    def perform(s)
      s.push(secondary.pop)
    end
  end

  class SecondaryExchange < SecondaryStackOperation
    def names
      ['xchg']
    end
    def perform(s)
      new_secondary = s.dup
      s.clear
      s.concat(secondary)
      secondary.clear
      secondary.concat(new_secondary)
    end
  end

  class Load < RegisterOperation
    def names
      ['load']
    end
    def perform(s)
      r = s.pop
      s.push(registers.has_key?(r) ? registers[r] : 0)
    end
  end

  class Load0 < RegisterOperation
    def names
      ['0load']
    end
    def perform(s)
      s.push(registers.has_key?(0) ? registers[0] : 0)
    end
  end

  class Load1 < RegisterOperation
    def names
      ['1load']
    end
    def perform(s)
      s.push(registers.has_key?(1) ? registers[1] : 0)
    end
  end

  class Load2 < RegisterOperation
    def names
      ['2load']
    end
    def perform(s)
      s.push(registers.has_key?(2) ? registers[2] : 0)
    end
  end

  class Load3 < RegisterOperation
    def names
      ['3load']
    end
    def perform(s)
      s.push(registers.has_key?(3) ? registers[3] : 0)
    end
  end

  class Store < RegisterOperation
    def names
      ['store']
    end
    def perform(s)
      registers[s.pop] = s.pop
    end
  end

  class Store0 < RegisterOperation
    def names
      ['0store']
    end
    def perform(s)
      registers[0] = s.pop
    end
  end

  class Store1 < RegisterOperation
    def names
      ['1store']
    end
    def perform(s)
      registers[1] = s.pop
    end
  end

  class Store2 < RegisterOperation
    def names
      ['2store']
    end
    def perform(s)
      registers[2] = s.pop
    end
  end

  class Store3 < RegisterOperation
    def names
      ['3store']
    end
    def perform(s)
      registers[3] = s.pop
    end
  end


  # Map of builtin operation names to definitions
  BUILTIN_OPERATIONS = {}
  ObjectSpace.each_object(Class) do |c|
    if c.ancestors.include?(BuiltinOperation) &&
        !c.ancestors.include?(SecondaryStackOperation) &&
        !c.ancestors.include?(RegisterOperation) &&
        c.public_method_defined?(:perform)
      op = c.new
      op.names.each do |name|
        BUILTIN_OPERATIONS[name] = op
      end
    end
  end
  BUILTIN_OPERATIONS.freeze


  # User-defined operations consist of a sequence of numbers and
  # other operations.  Numbers are pre-parsed, and are placed
  # directly on the stack.  Operations are performed.
  class CustomOperation < Operation

    def initialize(name, sequence)
      @name = name
      @sequence = sequence
    end

    def names
      [@name]
    end

    def perform(s)
      @sequence.each do |arg|
        if arg.kind_of?(Operation)
          arg.perform(s) do |result|
            yield result
          end
        else
          s.push(arg)
        end
      end
    end
  end


  # Things can go wrong...
  class RPNException < StandardError
  end
  class ParseException < RPNException
  end


  # standard arrays work as stacks, but don't fail if popped when empty.
  # They return nil instead.  A predictable, instant failure is easier
  # to handle, so we'll make a stack subclass that does just that
  class Stack < Array
    def pop
      raise StackUnderflowException.new(nil, self) if size == 0
      super
    end
  end
  class StackUnderflowException < RPNException
    attr_reader :stack

    def initialize(msg = nil, stack = nil)
      super(msg)
      @stack = stack
    end
  end


  # RPN evaluation engine.  Not thread-safe
  class Evaluator

    # Tokens which start and end op definitions
    DEFINITION_START = /^(:|def)$/
    DEFINITION_END = /^(;|end)$/


    # An array with a counter tracking progress through it
    class Sequence

      def initialize(args)
        if args.kind_of?(Array)
          @array = args
        else
          @array = args.to_s.split
        end
        @i = -1
      end

      def current
        @array[@i]
      end

      def next
        @i += 1
        current
      end

      def has_next?
        (@i + 1) < @array.size
      end

      def position
        # 1-based position
        @i + 1
      end

      def size
        @array.size
      end
    end


    attr_reader :registers, :stack, :secondary_stack


    # Constructor
    def initialize

      @stack = Stack.new
      @secondary_stack = Stack.new
      @registers = {}

      @operations = BUILTIN_OPERATIONS.dup
      ObjectSpace.each_object(Class) do |c|
        if c.ancestors.include?(SecondaryStackOperation) &&
            c.public_method_defined?(:perform)
          op = c.new(@secondary_stack)
          op.names.each do |name|
            @operations[name] = op
          end
        elsif c.ancestors.include?(RegisterOperation) &&
            c.public_method_defined?(:perform)
          op = c.new(@registers)
          op.names.each do |name|
            @operations[name] = op
          end
        end
      end

    end


    # Evaluates the supplied arguments.  Output from operations is
    # passed to the supplied block "output".  Returns anything left
    # on the stack
    def eval(args, &output)
      @sequence = sequence = Sequence.new(args)

      # main loop
      while sequence.has_next? do
        arg = sequence.next

        begin
          name = arg.chomp.downcase

          if DEFINITION_START.match(name)
            define_operation
            next
          end

          op = @operations[name]
          if op
            op.perform(stack, &output)
          else
            # parse argument as number and push it
            stack.push(parse_current)
          end

        rescue StackUnderflowException
          # which stack was it?
          itwas = ($!.stack.equal?(stack)) ? "stack" : "secondary stack"
          posn = sequence.position
          raise StackUnderflowException \
            .new("#{itwas} underflow at argument #{posn} (\"#{arg}\")")
        end
      end

      stack
    end


    private

    # Parses the sequence until an end token is found.
    # Uses the parsed sequence to generate a custom operator
    def define_operation
      sequence = @sequence
      start = sequence.position
      name = nil
      operation_sequence = []

      while sequence.has_next?
        arg = sequence.next.chomp.downcase

        if DEFINITION_END.match(arg)
          raise ParseException \
            .new("empty definition at argument #{start}") unless name
          @operations[name] = CustomOperation.new(name, operation_sequence)
          return
        elsif DEFINITION_START.match(arg)
          raise ParseException \
            .new("nested definition at argument #{sequence.position}")
        elsif name
          op = @operations[arg]
          if op
            operation_sequence << op
          else
            operation_sequence << parse_current
          end
        else
          # first argument is the operation's name
          name = arg
          op = @operations[name]
          raise ParseException \
            .new("attempted to redefine builtin \"#{name}\"" + \
                 " in definition starting at argument #{start}") \
            if op && op.kind_of?(BuiltinOperation)
        end
      end

      raise ParseException \
        .new("definition starting at argument #{start} unterminated")
    end


    # Attempts to parse the current argument in the sequence as a number
    def parse_current
      arg = @sequence.current
      if arg.kind_of?(Numeric)
        arg
      else
        # attempt to parse argument as a real if it contains a point
        # otherwise assume integer
        number_arg = @sequence.current.chomp
        if number_arg.include?('.')
          # the parser chokes on trailing points -- append a zero
          number_arg << '0' if /\.$/.match(number_arg)
          ('%f' % number_arg).to_f
        else
          ('%d' % number_arg).to_i
        end
      end
    rescue ArgumentError
      raise ParseException.new("argument #{ \
          @sequence.position} (\"#{@sequence.current}\") unparseable")
    end

  end

end
