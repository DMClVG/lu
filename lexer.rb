class DoToken end

class IdentifierToken
  attr_reader :name
  def initialize name
    @name = name
  end
  def to_s
    @name.to_s
  end
end


class BlockToken < Array
end

class Lexer
  def initialize(s)
    @s = s
    @i = 0
  end

  def char
    @s[@i]
  end

  def parse
    tree = BlockToken.new
    until char == nil
      token = parse_token
      tree << token
      skip_whitespace
    end
    tree
  end

  def skip_whitespace
    @i += 1 while char =~ /\s/
  end

  def skip_line
    @i += 1 until char == "\n"
  end

  def parse_token
    skip_whitespace

    case char
    when nil
      abort "FIXME"
    when '\\'
      skip_line
      parse_token
    when '!'
      @i += 1
      DoToken.new
    when ':'
      @i += 1
      symbol = parse_symbol
      return IdentifierToken.new :':' if symbol.nil?
      symbol
    when '['
      parse_block
    when '"'
      parse_string
    when /\d/
      parse_number
    else
      symbol = parse_symbol
      IdentifierToken.new symbol
    end
  end

  def parse_symbol
    ret = @s[@i..@s.length][/\A[=<>\w\.@:&$%\?\*\^_\+\-#]+/]
    return ret if ret == nil
    @i += ret.length
    ret.to_sym
  end

  def parse_number
    ret = @s[@i..@s.length][/\A[\d]+/]
    @i += ret.length
    ret.to_i
  end

  def parse_string
    endquote = '"'

    regex = nil
    if endquote == '"' then
      regex = /\A"(?:[^"\\]|\\.)*"/
    elsif endquote == "'" then
      regex = /\A'(?:[^'\\]|\\.)*'/
    end
    ret = @s[@i..@s.length][regex]
    @i += ret.length
    ret.undump
  end

  def parse_block
    @i += 1
    list = BlockToken.new
    until char == "]"
      token = parse_token
      if token != nil then
        list << token
      end
      skip_whitespace
      if char == nil then
        abort "Unclosed block"
      end
    end
    @i += 1
    list
  end
end
