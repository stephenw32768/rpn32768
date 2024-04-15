# rpn32768—a command-line RPN calculator

## What is it?

It's a simple [reverse Polish notation](https://en.wikipedia.org/wiki/Reverse_Polish_notation) calculator that
can be run to evaluate a single expression, or interactively.

## Prerequisites

It's written in Ruby and requires a version of the Ruby interpreter that isn't completely ancient.  I use
whatever happens to be shipped by Fedora; anything later than 2.0 is probably okay.

## Installation

To install the wrapper script as in `PREFIX/bin/rpn` and the Ruby files in `PREFIX/share/ruby`, do:
```bash
bash$ rake install[PREFIX]
```

## Usage

### One-shot usage

You just write an arithmetic expression in RPN.  Evaluation is left-to-right; numbers are pushed onto the stack,
operators pop their arguments from the stack and push their results back onto the stack.  Anything left on the
stack is printed to standard output.

#### Example

```bash
bash$ rpn 1 2 3 + +
6
```

### Interactive usage

Type `rpn` with no arguments.  You are left at an `rpn>` prompt.  You can type expressions; the stack is preserved
between each line.  Type `.` to pop a number from the stack and print it.  If `rlwrap` is on your path, you get
line editing and history.

#### Example

```bash
bash$ rpn
rpn> 6 2 3
rpn> +
rpn> .
5
rpn> sqr .
36
```

### Supported operators

Type `help` for a list.  Type `help OPERATOR` for a description of `OPERATOR`.  Some operators have synonyms; type
`help full` for a complete list including synonyms.

```bash
bash$ rpn help
```