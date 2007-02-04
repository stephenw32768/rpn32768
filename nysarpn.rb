#!/usr/bin/ruby

#
# Command-line RPN calculator
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

RCSID = "$Id$"


# marker superclass from which all calculator operation classes inherit
class Operation
end

# one class per calculator operation
# "names" method returns the names which should invoke the operation
# "perform" method performs the operation on the supplied stack

class Plus < Operation
  def names
    ['+']
  end
  def perform(s)
    s.push(s.pop + s.pop)
  end
end

class Minus < Operation
  def names
    ['-']
  end
  def perform(s)
    s.push(0 - s.pop + s.pop)
  end
end

class Multiply < Operation
  def names
    ['x', '*']
  end
  def perform(s)
    s.push(s.pop * s.pop)
  end
end

class Divide < Operation
  def names
    ['/']
  end
  def perform(s)
    divisor = s.pop
    s.push(s.pop / divisor)
  end
end

class Modulo < Operation
  def names
    ['%', 'mod']
  end
  def perform(s)
    divisor = s.pop
    s.push(s.pop % divisor)
  end
end

class Negate < Operation
  def names
    ['neg']
  end
  def perform(s)
    s.push(0 - s.pop)
  end
end

class Modulus < Operation
  def names
    ['abs']
  end
  def perform(s)
    s.push(s.pop.abs)
  end
end

class Reciprocal < Operation
  def names
    ['inv']
  end
  def perform(s)
    s.push(1.0 / s.pop)
  end
end

class Factorial < Operation
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

class Square < Operation
  def names
    ['sqr']
  end
  def perform(s)
    s.push(s.pop ** 2)
  end
end

class Raise < Operation
  def names
    ['**', 'pow', 'raise']
  end
  def perform(s)
    power = s.pop
    s.push(s.pop ** power)
  end
end

class SquareRoot < Operation
  def names
    ['sqrt']
  end
  def perform(s)
    s.push(Math.sqrt(s.pop))
  end
end

class Root < Operation
  def names
    ['root']
  end
  def perform(s)
    power = (1.0 / s.pop)
    s.push(s.pop ** power)
  end
end

class CommonLogarithm < Operation
  def names
    ['log']
  end
  def perform(s)
    s.push(Math.log10(s.pop))
  end
end

class NaturalLogarithm < Operation
  def names
    ['ln']
  end
  def perform(s)
    s.push(Math.log(s.pop))
  end
end

class Euler < Operation
  def names
    ['e']
  end
  def perform(s)
    s.push(Math::E)
  end
end

class Pi < Operation
  def names
    ['pi']
  end
  def perform(s)
    s.push(Math::PI)
  end
end

class DegreesToRadians < Operation
  def names
    ['dtor']
  end
  def perform(s)
    s.push(s.pop * Math::PI / 180)
  end
end

class RadiansToDegrees < Operation
  def names
    ['rtod']
  end
  def perform(s)
    s.push(s.pop * 180 / Math::PI)
  end
end

class Sine < Operation
  def names
    ['sin']
  end
  def perform(s)
    s.push(Math.sin(s.pop))
  end
end

class InverseSine < Operation
  def names
    ['asin']
  end
  def perform(s)
    s.push(Math.asin(s.pop))
  end
end

class Cosine < Operation
  def names
    ['cos']
  end
  def perform(s)
    s.push(Math.cos(s.pop))
  end
end

class InverseCosine < Operation
  def names
    ['acos']
  end
  def perform(s)
    s.push(Math.acos(s.pop))
  end
end

class Tangent < Operation
  def names
    ['tan']
  end
  def perform(s)
    s.push(Math.tan(s.pop))
  end
end

class InverseTangent < Operation
  def names
    ['atan']
  end
  def perform(s)
    s.push(Math.atan(s.pop))
  end
end

class FahrenheitToCentigrade < Operation
  def names
    ['ftoc']
  end
  def perform(s)
    s.push((s.pop - 32) * 5 / 9)
  end
end

class CentigradeToFahrenheit < Operation
  def names
    ['ctof']
  end
  def perform(s)
    s.push(s.pop * 9 / 5 + 32)
  end
end

class BitwiseAnd < Operation
  def names
    ['&', 'and']
  end
  def perform(s)
    s.push(s.pop.to_i & s.pop.to_i)
  end
end

class BitwiseOr < Operation
  def names
    ['|', 'or']
  end
  def perform(s)
    s.push(s.pop.to_i | s.pop.to_i)
  end
end

class BitwiseXor < Operation
  def names
    ['^', 'xor']
  end
  def perform(s)
    s.push(s.pop.to_i ^ s.pop.to_i)
  end
end

class BitwiseNot < Operation
  def names
    ['~', 'not']
  end
  def perform(s)
    s.push(~(s.pop.to_i))
  end
end

class ShiftLeft < Operation
  def names
    ['shl']
  end
  def perform(s)
    places = s.pop
    s.push(s.pop << places)
  end
end

class ShiftRight < Operation
  def names
    ['shr']
  end
  def perform(s)
    places = s.pop
    s.push(s.pop >> places)
  end
end

class Duplicate < Operation
  def names
    ['d', 'dup']
  end
  def perform(s)
    i = s.pop
    s.push(i).push(i)
  end
end

class Duplicate2 < Operation
  def names
    ['2dup']
  end
  def perform(s)
    x = s.pop
    y = s.pop
    s.push(y).push(x).push(y).push(x)
  end
end

class Swap < Operation
  def names
    ['s', 'swap']
  end
  def perform(s)
    upper = s.pop
    lower = s.pop
    s.push(upper).push(lower)
  end
end

class Drop < Operation
  def names
    ['p', 'pop', 'drop']
  end
  def perform(s)
    s.pop
  end
end

class ToInteger < Operation
  def names
    ['to_i']
  end
  def perform(s)
    s.push(s.pop.to_i)
  end
end

class ToReal < Operation
  def names
    ['to_f', 'to_r']
  end
  def perform(s)
    s.push(s.pop.to_f)
  end
end

class Print < Operation
  def names
    ['.']
  end
  def perform(s)
    puts(s.pop)
  end
end

class PrintHex < Operation
  def names
    ['.x']
  end
  def perform(s)
    puts("0x#{'%x' % s.pop}")
  end
end

class PrintOctal < Operation
  def names
    ['.o']
  end
  def perform(s)
    puts("0#{'%o' % s.pop}")
  end
end

class PrintBinary < Operation
  def names
    ['.b']
  end
  def perform(s)
    puts("0b#{'%b' % s.pop}")
  end
end


# create map of operation names to definitions
operations = {}
ObjectSpace.each_object(Class) do |c|
  if c.ancestors.include?(Operation) && (c != Operation)
    op = c.new
    op.names.each do |name|
      operations[name] = op
    end
  end
end


# standard arrays work as stacks, but don't fail if popped when empty.
# They return nil instead.  A predictable, instant failure is easier
# to handle, so we'll make a stack subclass that does just that
class Stack < Array
  def pop
    raise StackUnderflowError.new if size == 0
    super
  end
end
class StackUnderflowError < Exception
end

stack = Stack.new


# main loop
i = 0
ARGV.each do |arg|
  begin
    i += 1
    op = operations[arg.chomp.downcase]
    if op
      op.perform(stack)
    else
      # parse argument as number and push it
      begin
        # attempt to parse argument as a real if it contains a point
        # otherwise assume integer
        number_arg = arg.chomp
        if number_arg.include?('.')
          # the parser chokes on trailing points -- append a zero
          number_arg << '0' if /\.$/.match(number_arg)
          stack.push(('%f' % number_arg).to_f)
        else
          stack.push(('%d' % number_arg).to_i)
        end
      rescue ArgumentError
        STDERR.puts("argument #{i} (\"#{arg}\") unparseable")
        exit(1)
      end
    end

  rescue StackUnderflowError
    STDERR.puts("stack underflow at argument #{i} (\"#{arg}\")")
    exit(1)
  end
end

# print anything left on the stack
while stack.size > 0
  puts(stack.pop)
end
