require "colorize"

require_relative "sy"
require_relative "lang/lexer"
require_relative "lang/env"
require_relative "lang/exec"
# require_relative "lang/analyzer"
require_relative "lang/source"

def print_error_with_marked_token source, message, token
  def indent n
    n.times { print " " }
  end

  def newline
    puts ""
  end

  newline

  puts message.colorize(:red)
  line = (source.get_line_at token.first)

  line_number_prefix = line.line_number.to_s + ": "

  top_indent = line_number_prefix.length
  indent = token.first - line.first
  length = token.last - token.first

  print line_number_prefix
  print line.value[0...indent]
  print line.value[indent...indent+length].colorize(:color => :red, :mode => :bold)
  print line.value[indent+length..-1]

  indent top_indent + indent
  length.times { print "^".colorize(:red) }

  newline
end

input = ARGV[0]
code = File.open(input).read
source = Source.new code

begin
  tree = Lexer::Tokenizer.new(code).tokenize
rescue Lexer::TokenizerException => e
  case e
  when Lexer::UnclosedBlockException
    print_error_with_marked_token source, "block was never closed", e.token
  when Lexer::UnexpectedTokenException
    print_error_with_marked_token source, "expected " + e.expected + " here", e.token
  else
    raise e
  end
  return
end

env = Environment.new Source.new(code), tree
env.parse_tree

m = Sy.new

begin
  Executor.new(m, env).execute
rescue Executor::ExecutionException => e
  case e
  when Executor::UndefinedWordException
    print_error_with_marked_token source, ("undefined word '" + e.token.value.to_s + "'"), e.token
  when Executor::StackUnderflowException
    print_error_with_marked_token source, "stack underflowed", e.token
  else
    raise e
  end
end
