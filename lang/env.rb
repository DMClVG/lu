require_relative "lexer"

class Environment
  attr_reader :entry, :words, :structs, :source

  class Word
    attr_reader :name, :body

    def initialize name, body
      @name = name
      @body = body
    end
  end

  class Struct
    attr_reader :name, :attributes, :words, :methods
    def initialize name, attributes
      @name = name
      @attributes = attributes
      @words = Hash.new
      @methods = Hash.new
    end
  end

  def initialize source, tree
    @source = source
    @tree = tree.value.clone
    @words = Hash.new
    @structs = Hash.new
    @entry = nil
  end

  def next_token
    @tree.shift
  end

  def next_token_expect type, msg
    token = next_token
    abort msg if token.nil? or not token.value.is_a?(type)

    token
  end

  def invalid_token_error token
    abort "invalid token " + token.class.to_s
  end

  def parse_tree
    while true
      token = next_token
      return nil if token.nil?

      if token.value.is_a?(Symbol) and token.value == :':' then
        name = next_token_expect(Symbol, "expected name here").value
        body = next_token_expect(Array, "expected word body here")
        define Word.new name, body

      elsif token.value.is_a?(Symbol) and token.value == :'@' then
        name = next_token_expect(Symbol, "expected name here").value
        attributes = next_token_expect(Array, "expected struct attributes here")
        define Struct.new name, attributes

      elsif token.value.is_a?(Symbol) then
        struct = @structs[token.value]
        case op = next_token.value
        when :':'
          word_name = next_token_expect(Symbol, "expected symbol here")
          word_body = next_token_expect(Array, "expected block here")
          struct.words[word_name.value] = (Word.new word_name, word_body)
        when :'*'
          word_name = next_token_expect(Symbol, "expected symbol here")
          word_body = next_token_expect(Array, "expected block here")
          struct.methods[word_name.value] = (Word.new word_name, word_body)
        else
          invalid_token_error op
        end
      elsif token.value.is_a?(Lexer::DoOp) then

        body = next_token
        abort "redefining entry point" if not @entry.nil?

        @entry = body
      else
        invalid_token_error token
      end
    end
    if @entry.nil? then abort "no entry point defined" end
  end

  def define object
    if object.is_a?(Word) then
      if not @words.has_key?(object.name) then
        @words[object.name] = object
      else
        abort "word " + object.name.to_s + " already defined"
      end
    elsif object.is_a?(Struct) then
      if not @structs.has_key?(object.name) then
        @structs[object.name] = object
      else
        abort "structure " + object.name.to_s + " already defined"
      end
    end
  end
end
