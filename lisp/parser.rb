class BindList < Array 
end

class ExpressionList < Array 
end

class BlockList < Array 
end

class EsyParser
  def initialize(s)
    @s = s
    @i = 0
    @inbind = false
  end

  def char
    @s[@i] 
  end

  def parse
    tree = []
    until char == nil
      tree << parse_node
      skip_whitespace
    end
    BlockList.new tree
  end

  def skip_whitespace
    @i += 1 while char =~ /\s/
  end

  def skip_line
    @i += 1 until char == '\n'
  end

  def parse_symbol
    ret = @s[@i..@s.length][/\A[\w:#@!&$%\?\*\^_\+]+/]
    @i += ret.length 
    ret.to_sym
  end

  def parse_number
    ret = @s[@i..@s.length][/\A[\d]+/]
    @i += ret.length 
    ret.to_i
  end

  def parse_node
    skip_whitespace

    case char
    when nil
      abort "FIXME"
    when ';'
      skip_line
      parse_node
    when '|'
      parse_list BindList.new
    when '('
      parse_list ExpressionList.new
    when '['
      parse_list BlockList.new
    when '"'
      parse_string
    when /\d/
      parse_number
    else
      parse_symbol
    end
  end

  def getdelimiter c
    case c
    when "("
      ")"
    when "["
      "]"
    else c
    end
  end

  def parse_string
    endquote = getdelimiter char

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

  def parse_list list
    delimiter = getdelimiter char
    @i += 1
    until char == delimiter or char == nil
      list << parse_node
      skip_whitespace
    end
    @i += 1 if char == delimiter
    list
  end
end

