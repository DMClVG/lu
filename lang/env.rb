require_relative "lexer"

class EnvironmentParser
  class EnvironmentParserException < StandardError
    attr_reader :token
    def initialize token
      @token = token
    end
  end

  class EntryAlreadyDefinedException < EnvironmentParserException
    def message
      "entry was already defined elsewhere"
    end
  end

  class UnexpectedTokenException < EnvironmentParserException
    def message
      "unexpected token"
    end
  end

  class WordAlreadyDefinedException < EnvironmentParserException
    attr_reader :word_name, :previous_occurence
    def initialize token, previous_occurence, name
      super token
      @previous_occurence = previous_occurence
      @word_name = name
    end

    def message
      "word '" + word_name + "' was already defined"
    end
  end

  def initialize env, tree
    @tree = tree.value
    @env = env
  end

  def next_token
    @tree.shift
  end

  def next_token_expect type
    token = next_token
    raise UnexpectedTokenException.new token if token.nil? or not token.value.is_a?(type)
    token
  end

  def require_module mod
    path = mod.gsub(".", "/") + ".fth"

    source = SourceWithPath.load_from_file(path)
    lexer = Lexer::Tokenizer.new source
    tk = lexer.tokenize

    @env.add_require mod
    EnvironmentParser.new(@env, tk).parse
  end

  def parse
    while not (token = next_token).nil?

      if token.value.is_a?(Symbol) and token.value == :':' then
        name = next_token_expect(Symbol)
        body = next_token_expect(Array)

        raise WordAlreadyDefinedException.new name, nil, name.value.to_s if @env.words.key?(name.value)
        @env.define Environment::Word.new name.value, body

      elsif token.value.is_a?(Lexer::DoOp) then
        body = next_token_expect(Array)

        raise EntryAlreadyDefinedException.new token if not @env.entry.nil?
        @env.define Environment::Entry.new(:entry, body)

      elsif token.value.is_a?(Lexer::RequireDirective) then
        mod = token.value.mod.value
        require_module mod if not @env.required?(mod)

      else
        raise UnexpectedTokenException.new token
      end
    end
  end
end

class Environment
  attr_reader :entry, :words, :required_modules

  class Word
    attr_reader :name, :body

    def initialize name, body
      @name = name
      @body = body
    end
  end

  class Entry < Word; end

  def initialize
    @words = Hash.new
    @structs = Hash.new
    @entry = nil
    @required_modules = []
  end

  def required? mod
    @required_modules.include?(mod)
  end

  def add_require mod
    @required_modules << mod
  end

  def define object
    if object.is_a?(Entry) then
        @entry = object
    elsif object.is_a?(Word) then
      if not @words.has_key?(object.name) then
        @words[object.name] = object
      end
    end
  end
end
