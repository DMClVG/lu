module Lexer
  class TokenizerException < StandardError; end

  class UnexpectedTokenException < TokenizerException
    attr_reader :token, :expected
    def initialize token, expected
      @token = token
      @expected = expected
    end
  end

  class UnclosedBlockException < TokenizerException
    attr_reader :token
    def initialize token
      @token = token
    end
  end

  class Token
    attr_reader :first, :last, :value

    def initialize first, last, value
      @value = value
      @first = first
      @last = last
    end
  end

  class SingleBodyBlock
    attr_reader :body

    def initialize body
      @body = body
    end

    def == other
      other.is_a?(self.class) and other.body == @body
    end
  end

  class ElseBlock < SingleBodyBlock
  end

  class ThenBlock < SingleBodyBlock
  end

  class RangeBlock < SingleBodyBlock
  end

  class TimesBlock < SingleBodyBlock
  end
  class EachBlock < SingleBodyBlock; end

  class ThenElseBlock
    attr_reader  :then_body, :else_body

    def initialize then_body, else_body
      @then_body = then_body
      @else_body = else_body
    end

    def == other
      other.is_a?(ThenElseBlock) and other.then_body == @then_body and other.else_body == @else_body
    end
  end

  class WhileBlock
    attr_reader  :condition_body, :loop_body

    def initialize condition_body, loop_body
      @condition_body = condition_body
      @loop_body = loop_body
    end

    def == other
      other.is_a?(WhileBlock) and other.condition_body == @condition_body and other.loop_body == @loop_body
    end
  end

  class UntilBlock
    attr_reader  :condition_body, :loop_body

    def initialize condition_body, loop_body
      @condition_body = condition_body
      @loop_body = loop_body
    end

    def == other
      other.is_a?(UntilBlock) and other.condition_body == @condition_body and other.loop_body == @loop_body
    end
  end

  class DoOp
    def == other
      other.is_a?(DoOp)
    end
  end

  class StringIterator
    def initialize string
      @s = string
      @p = 0
    end

    def jump p
      @p = p
    end

    def position
      @p
    end

    def peek
      @s[@p + 1]
    end

    def char
      @s[@p]
    end

    def next
      @p += 1
    end

    def first
      0
    end

    def last
      @s.length
    end

    def string
      @s
    end
  end

  class Tokenizer
    def initialize(s)
      @s = StringIterator.new s
    end

    def tokenize
      tree = Array.new

      until @s.char == nil
        token = consume_token
        abort if token.nil?
        tree << token
        skip_whitespace
      end

      Token.new @s.first, @s.last, tree
    end

    def skip_whitespace
      @s.next while @s.char =~ /\s/
    end

    def skip_line
      @s.next until @s.char == "\n"
    end

    def advance token
      @s.jump token.last
      token
    end

    def match_and_consume_prefixed_block sym
        tk = match_symbol
        return nil if tk.nil?

        if tk.value == sym
          advance tk
          return consume_block
        else
          return nil
        end
    end

    def expect_symbol sym
      tk = match_symbol
      raise UnexpectedTokenException.new tk, sym.to_s if tk.value != sym
      advance tk
    end

    def match_and_consume_prefixed_condition_do_body class_constructor, prefix
        tk = match_symbol
        return nil if tk.nil?

        if tk.value == prefix
          advance tk
          condition_body = consume_block
          expect_symbol :do
          loop_body = consume_block
          return class_constructor.new condition_body, loop_body
        else
          return nil
        end
    end

    def match_and_consume_while
      match_and_consume_prefixed_condition_do_body WhileBlock, :while
    end

    def match_and_consume_until
      match_and_consume_prefixed_condition_do_body UntilBlock, :until
    end

    def match_and_consume_else
      match_and_consume_prefixed_block :else
    end

    def match_and_consume_range
      match_and_consume_prefixed_block :range
    end

    def match_and_consume_then
      match_and_consume_prefixed_block :then
    end

    def match_and_consume_each
      match_and_consume_prefixed_block :each
    end

    def match_and_consume_times
      match_and_consume_prefixed_block :times
    end

    def consume_token
      skip_whitespace

      if @s.char == '\\' then
        skip_line
        return consume_token
      end

      case @s.char
      when nil
        abort "FIXME"
      when '!'
        advance(Token.new @s.position, @s.position + 1, DoOp.new)
      when '['
        consume_block
      when '"'
        advance match_string
      else
        if not (then_body = match_and_consume_then).nil? then
          if not (else_body = match_and_consume_else).nil? then

            return Token.new then_body.first, else_body.last, ThenElseBlock.new(then_body, else_body)
          else

            return Token.new then_body.first, then_body.last, ThenBlock.new(then_body)
          end
        elsif not (else_body = match_and_consume_else).nil? then

          return Token.new else_body.first, else_body.last, ElseBlock.new(else_body)

        elsif not (range_body = match_and_consume_range).nil? then

          return Token.new range_body.first, range_body.last, RangeBlock.new(range_body)

        elsif not (times_body = match_and_consume_times).nil? then

          return Token.new times_body.first, times_body.last, TimesBlock.new(times_body)
        elsif not (while_block = match_and_consume_while).nil? then

          return Token.new while_block.condition_body.first, while_block.loop_body.last, while_block
        elsif not (until_block = match_and_consume_until).nil? then

          return Token.new until_block.condition_body.first, until_block.loop_body.last, until_block
        elsif not (each_body = match_and_consume_each).nil? then

          return Token.new each_body.first, each_body.last, EachBlock.new(each_body)
        else
          advance match_symbol
        end
      end
    end

    def match pattern, block
      skip_whitespace

      first = @s.position

      matched = @s.string[@s.position..@s.last][pattern]

      return nil if matched.nil?

      last = @s.position + matched.length
      value = block.call(matched)

      Token.new first, last, value
    end

    def match_symbol
      match /\A[=<>\/\w\d\.@:&$%\?\*\^_\+\-#]+/, Proc.new { |matched|
        if /\A[-+]?\d+\z/ === matched then
          matched.to_i
        else
          matched.to_sym
        end
      }
    end

    def match_string
      match (/\A"(?:[^"\\]|\\.)*"/), Proc.new { |matched|
        matched.undump
      }
    end

    def consume_block
      skip_whitespace

      if @s.char == '[' then
        open_bracket = (Token.new @s.position, @s.position+1, @s.char)
        first = @s.position
        @s.next # skip '['

        block = Array.new

        until @s.char == "]"
          token = consume_token
          abort if token.nil?

          block << token

          skip_whitespace

          if @s.char == nil then
            raise UnclosedBlockException.new open_bracket
          end
        end

        @s.next # skip ']'
        last = @s.position
        Token.new first, last, block
      else
        token = consume_token
        Token.new token.first, token.last, [ token ]
      end
    end
  end

end
