require_relative "lexer"

class Environment
  attr_reader :entry, :words, :source

  class Word
    attr_reader :name, :body

    def initialize name, body
      @name = name
      @body = body
    end
  end

  def initialize source, tree
    @source = source
    @tree = tree.value.clone
    @words = Hash.new
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
        abort "word " + name.to_s + " already defined"
      end
    end
  end
end
