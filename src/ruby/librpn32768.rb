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

  require_relative 'librpn32768/exceptions'
  require_relative 'librpn32768/operations'

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

    # Tokens which start and end alias definitions
    DEFINITION_START = /^(:|def)$/
    DEFINITION_END = /^(;|end)$/

    # Tokens for displaying help
    HELP = 'help'

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

    class Help
      attr_reader :op_name, :short, :full

      # The first line is the operator name followed by the short description.
      # The rest of the lines are the full description
      def initialize(lines)
        @op_name = lines[0].sub(/\s.*/, '')
        @short = lines[0].sub(/^\S+\s/, '')
        @full = lines.drop(1)
      end
    end

    attr_reader :heap, :stack, :secondary_stack


    # Constructor
    def initialize

      @stack = Stack.new
      @secondary_stack = Stack.new
      @heap = {}

      @operations = {}
      @aliases = {}
      ObjectSpace.each_object(Class) do |c|
        op = nil
        if c.ancestors.include?(HeapOperation) &&
            c.public_method_defined?(:perform)
          op = c.new(@stack, @heap)
        elsif c.ancestors.include?(SecondaryStackOperation) &&
            c.public_method_defined?(:perform)
          op = c.new(@stack, @secondary_stack)
        elsif c.ancestors.include?(StackOperation) &&
            c.public_method_defined?(:perform)
          op = c.new(@stack)
        end

        if op
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
            define_alias
            next
          end

          if name == HELP
            show_help(&output)
            next
          end

          op = @operations[name]
          op = @aliases[name] if op == nil
          if op
            op.perform(&output)
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
        rescue OperandOutOfRangeException
          # rethrow with context
          posn = sequence.position
          raise $!.class.new("#{$!.message} at argument #{posn} (\"#{arg}\")")
        end
      end

      stack
    end


    private

    # Parses the sequence until an end token is found.  Uses the parsed sequence to generate an alias
    def define_alias
      sequence = @sequence
      start = sequence.position
      name = nil
      operation_sequence = []

      while sequence.has_next?
        arg = sequence.next.chomp.downcase

        if DEFINITION_END.match(arg)
          raise ParseException \
            .new("empty definition at argument #{start}") unless name
          @aliases[name] =
            Alias.new(name, stack, operation_sequence)
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
            .new("attempted to redefine operation \"#{name}\"" + \
                 " in definition starting at argument #{start}") \
            if op
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

    # Lazy-loaded help
    def help
      return @help if defined?(@help)

      # find the help in the current directory or on the load path

      ([Dir.pwd] + $LOAD_PATH).map{|p| "#{p}/rpn32768help.txt"}.each do |path|
        if File.exist?(path)
          @help = {}
          # each help is delimited with a blank line
          IO.read(path).split(/\r?\n\s*\r?\n/).map do |help_lines|
            help = Help.new(help_lines.split(/\r?\n/))
            @help[help.op_name] = help
          end
          return @help
        end
      end

      raise StandardError('Help file rpn32768help.txt not found')
    end

    # Shows documentation
    def show_help(&output)
      if @sequence.has_next?
        arg = @sequence.next
        if arg == 'full'
          show_help_list(true, &output)
        else
          op = @operations[arg]
          raise ParseException.new("no such operator \"#{@sequence.current}\"") unless op
          show_op_help(op, &output)
        end
      else
        show_help_list(false, &output)
      end
    end

    # Shows documentation for a single operator
    def show_op_help(op)
      h = op.names.map { |n| help[n] }.filter { |x| x }[0]
      if h
        yield "Operator: #{h.op_name}"
        yield "Synonyms: #{op.names.join(", ")}" if op.names.length > 1
        yield h.short
        yield ''
        h.full.each do |line|
          yield line
        end
      else
        yield "No help available for operator \"#{@sequence.current}\""
      end
    end

    # Lists known operators
    def show_help_list(show_synonyms)
      op_names = help.keys
      op_names = @operations.values.flat_map { |op| op.names } if show_synonyms
      longest_op_name = op_names.map { |s| s.length }.max

      list = []
      help.keys.each do |op_name|
        synonyms = [op_name]
        synonyms = @operations[op_name].names if show_synonyms
        synonyms.each do |synonym|
          list << "#{synonym.ljust(longest_op_name)} #{help[op_name].short}"
        end
      end
      list.sort.each { |x| yield x }

      yield ''
      yield "For a full description of OPERATOR, use 'help OPERATOR'."
      yield "Some operators have synonyms, use 'help full' for a complete list." unless show_synonyms
    end
  end
end
