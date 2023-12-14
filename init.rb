require "colorize"
require "pathname"

require_relative "lu"
require_relative "lang/lexer"
require_relative "lang/env"
require_relative "lang/exec"
# require_relative "lang/analyzer"
require_relative "lang/source"

def print_error_with_marked_token message, token
  def indent n
    n.times { print " " }
  end

  def newline
    puts ""
  end

  source = token.source

  puts message.colorize(:red)
  lines = (source.get_lines_through token.first, token.last)

  if lines.length == 1 then
    line = lines.first
    error_prefix = line.line_number.to_s
    if source.is_a?(SourceWithPath) then
      error_prefix = source.path.to_s + ":" + error_prefix
    end
    error_prefix = "[" + error_prefix + "] "

    top_indent = error_prefix.length
    indent = token.first - line.first
    length = token.last - token.first

    print error_prefix.colorize(:gray)
    print line.value[0...indent]
    print line.value[indent...indent+length].colorize(:color => :red, :mode => :bold)
    print line.value[indent+length..-1]

    indent top_indent + indent
    length.times { print "^".colorize(:red) }

    newline
  else
    lines.each {|line|
      error_prefix = line.line_number.to_s
      if source.is_a?(SourceWithPath) then
        error_prefix = source.path.to_s + ":" + error_prefix
      end
      error_prefix = "[" + error_prefix + "] "

      print error_prefix.colorize(:gray)
      err_first, err_last =  [token.first - line.first, 0].max,
                            [token.last - line.first, line.value.length].min

      print line.value[0...err_first]
      print line.value[err_first...err_last].colorize(:red)
      print line.value[err_last...]
    }

    newline
  end

  exit
end

path = Pathname.new(ARGV[0])
source = SourceWithPath.load_from_file(path)

begin
  tree = Lexer::Tokenizer.new(source).tokenize
rescue Lexer::TokenizerException => e
  case e
  when Lexer::UnclosedBlockException
    print_error_with_marked_token "block was never closed", e.token
  when Lexer::UnexpectedTokenException
    print_error_with_marked_token "expected " + e.expected + " here", e.token
  else
    raise e
  end
  return
end

env = Environment.new

begin
  EnvironmentParser.new(env, tree).parse
rescue EnvironmentParser::EnvironmentParserException => e
  print_error_with_marked_token e.message, e.token
end


begin
  m = Lu.new
  Executor.new(m, env).execute
rescue Executor::ExecutionException => e
  puts ""
  case e
  when Executor::UndefinedWordException
    print_error_with_marked_token ("undefined word '" + e.token.value.to_s + "'"), e.token
  when Executor::StackUnderflowException
    print_error_with_marked_token "stack underflowed", e.token
  else
    raise e
  end
end
