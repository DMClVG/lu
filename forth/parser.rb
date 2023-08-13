module Forth
  class Node

  end

  class HereNode < Node
    
  end
  class NameNode < Node
    attr_reader :name
    def initialize name
      @name = name
    end
  end

  class BindNode < Node
    attr_reader :name
    def initialize name
      @name = name
    end
  end

  class DoNode < Node
  end

  class BlockNode < Array 
  end

  class Parser
    def initialize(s)
      @s = s
      @i = 0
    end

    def char
      @s[@i] 
    end

    def parse
      tree = BlockNode.new
      until char == nil
        tree << parse_node
        skip_whitespace
      end
      tree
    end

    def skip_whitespace
      @i += 1 while char =~ /\s/
    end

    def skip_line
      @i += 1 until char == '\n'
    end

    def parse_node
      skip_whitespace

      case char
      when nil
        abort "FIXME"
      when ';'
        skip_line
        parse_node
      when '!'
        @i += 1
        DoNode.new
      when '#'
        @i += 1
        HereNode.new
      when ':'
        @i += 1
        parse_symbol
      when '>'
        @i += 1
        BindNode.new parse_symbol
      when '['
        parse_block
      when '"'
        parse_string
      when /\d/
        parse_number
      else
        NameNode.new parse_symbol
      end
    end

    def parse_symbol
      ret = @s[@i..@s.length][/\A[\w:&$%\?\*\^_\+]+/]
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
      list = BlockNode.new
      until char == "]"
        list << parse_node
        skip_whitespace
        if char == nil then
          abort "Unclosed block"
        end
      end
      @i += 1
      list
    end
  end
end
