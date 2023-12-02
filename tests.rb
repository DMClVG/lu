require 'minitest/autorun'
require_relative "lang/lexer"
require_relative "lang/env"
require_relative "lang/exec"
require_relative "sy"

$timesthree = <<-TEXT
: timesthree [
  1 2 + *
]

! [
 5 timesthree
]
TEXT

class ExecutorTest < Minitest::Test

  def test_execute_timesthree
    tk = Lexer::Tokenizer.new($timesthree).tokenize
    puts tk.to_s
    env = Environment.new tk

    env.parse_tree

    m = Sy.new
    Executor.new(m, env).execute
    assert_equal(m.pop, 15)
  end
end

class TokenizerTest < Minitest::Test
  include Lexer

  def flatten_token_values token
    value = token.value

    case value
    when Array
      value.map { |token| flatten_token_values token }
    when ThenBlock
      ThenBlock.new flatten_token_values value.body
    when ElseBlock
      ElseBlock.new flatten_token_values value.body
    when ThenElseBlock
      ThenElseBlock.new (flatten_token_values value.then_body),
                        (flatten_token_values value.else_body)
    else
      value
    end
  end

  def test_timesthree
    tk = Lexer::Tokenizer.new $timesthree
    assert_equal flatten_token_values(tk.tokenize),
      [ :':', :timesthree, [ 1, 2, :+, :*], DoOp.new, [ 5, :timesthree ]]
  end

  def test_then_else
    tk = Lexer::Tokenizer.new "true 3243 **#*@ then [ happy abort ] else [ no ]"

    assert_equal flatten_token_values(tk.tokenize),
      [ :true, 3243, :'**#*@', ThenElseBlock.new([ :happy, :abort ], [ :no ])]
  end

  def test_then
    tk = Lexer::Tokenizer.new "true 3243 **#*@ then [ happy [ abort ] ]"

    assert_equal flatten_token_values(tk.tokenize),
      [ :true, 3243, :'**#*@', ThenBlock.new([ :happy, [ :abort ] ])]
  end

  def test_else
    tk = Lexer::Tokenizer.new "true 3243 **#*@ else [[ happy abort ] ]"

    assert_equal flatten_token_values(tk.tokenize),
      [ :true, 3243, :'**#*@', ElseBlock.new([ [:happy, :abort ] ])]
  end

  def test_unclosed_block
    tk = Lexer::Tokenizer.new "true 3243 **#*@ else [[ happy abort ]"
  end
end
