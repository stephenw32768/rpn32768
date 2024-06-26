#!/usr/bin/ruby

#
# Command-line RPN calculator
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

require 'librpn32768'

STRIP_COMMENT = /^([^#]*)/ ;# regex stripping anything after a hash mark

# Parses the contents of a file into an array of arguments
def parse_file(file)
  arr = []

  file.each_line do |line|
    line = STRIP_COMMENT.match(line)[1]
    arr.concat(line.split)
  end

  arr
end


include RPN32768


# Runs the evaluator interactively
def interactive(rpn)

  STDERR.print("rpn> ")
  STDIN.each_line do |line|
    printed = false
    begin
      rpn.eval(STRIP_COMMENT.match(line)[1]) do |x|
        if x.is_a?(String) && x.end_with?("\n")
          puts(x)
        else
          print("#{x} ")
        end
        printed = true
      end
    rescue RPNException => ex
      STDERR.puts(ex.message)
    end
    puts if printed
    STDERR.print("rpn> ")
  end
end


# Entry point
begin

  if ARGV.size > 0
    sequence = ARGV
  elsif !STDIN.tty?
    sequence = parse_file(STDIN)
  else
    sequence = nil
  end

  rpn = Evaluator.new
  if sequence
    rpn.eval(sequence) do |result|
      puts(result)
    end
  else
    interactive(rpn)
  end

  # print anything left on the stack
  while rpn.stack.size > 0
    puts("#{rpn.stack.pop}")
  end

rescue RPNException => ex
  STDERR.puts(ex.message)
  exit(1)
end
