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

RCSID = "$Id: nysarpn.rb,v 1.3 2007/02/10 17:10:40 stephen Exp stephen $"

require './libnysarpn'


# Parses the contents of a file into an array of arguments
def parse_file(file)
  arr = []
  strip_comment = /^([^\#]*)/ ;# anything after a hash mark is ignored

  file.each_line do |line|
    line = strip_comment.match(line)[1]
    arr.concat(line.split)
  end

  arr
end


include NysaRPN

begin
  sequence = (ARGV.size > 0) ? ARGV : parse_file(STDIN)

  stack = Evaluator.new.eval(sequence) do |result|
    puts(result)
  end

  # print anything left on the stack
  while stack.size > 0
    puts(stack.pop)
  end

rescue RPNException
  STDERR.puts($!.message)
  exit(1)
end
