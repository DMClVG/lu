
class Analyzer
  def initialize env
    @env = env
  end

  def underflow_error
    abort "stack will underflow"
  end

  def is_type stack_state, types
    return false if stack_state.length < types.length
    res = true
    types.each_with_index { |type, i|
      res = false if stack_state[-(i+1)] != type
    }
    res
  end

  def undefined_word_error word
    abort "undefined word " + word.to_s
  end

  def type_error
    abort "type error"
  end

  def branch_stack_analysis stack_state

  end

  def word_stack_analysis stack_state, word
    case word
    when String
      stack_state << String
    when Integer
      stack_state << Integer
    when IdentifierToken
      case word.name
      when :nl
      when :swap
        underflow_error if stack_state.length < 2
        a = stack_state.pop
        b = stack_state.pop
        stack_state << a
        stack_state << b
      when :type
        type_error unless is_type stack_state, [String] or is_type stack_state, [Integer]
        stack_state.pop
      when :'=', :'<>'
        type_error unless is_type stack_state, [Integer, Integer]
        stack_state.pop
        stack_state.pop
        stack_state << Integer
      when :+
        type_error unless is_type stack_state, [Integer, Integer]
        stack_state.pop
        stack_state.pop
        stack_state << Integer
      when :*
        type_error unless is_type stack_state, [Integer, Integer]
        stack_state.pop
        stack_state.pop
        stack_state << Integer
      when :dup
        last = stack_state.last
        underflow_error if last.nil?
        stack_state << last
      when :drop
        underflow_error if stack_state.last.nil?
        stack_state.pop
      when :'.s'
      else
        undefined_word_error(word.name.to_s) unless @env.word? word.name
        word_stack_analysis stack_state, @env.words[word.name]
      end
    when BlockToken
      word = word.clone
      loop do
        t = word.shift
        break if t.nil?
        if t.is_a?(IdentifierToken) and (t.name == :then or t.name == :else) then
          type_error unless is_type stack_state, [Integer]
          stack_state.pop
          sub_stack_state = stack_state.clone
          word_stack_analysis(sub_stack_state, word.shift)
          abort "stack is dirty" unless sub_stack_state == stack_state
        elsif t.is_a?(IdentifierToken) and (t.name == :range) then
          type_error unless is_type stack_state, [Integer, Integer]
          stack_state.pop
          stack_state.pop

          sub_stack_state = stack_state.clone
          sub_stack_state << Integer
          word_stack_analysis(sub_stack_state, word.shift)

          abort "stack is dirty" unless sub_stack_state == stack_state
        else
          word_stack_analysis(stack_state, t)
        end
      end
    else
      abort "err"
    end
  end

  def analyze
    word_stack_analysis [], @env.entry
  end
end

class Environment
  attr_reader :entry, :words

  def initialize tree
    @tree = tree
    @words = Hash.new
    @entry = nil
  end

  def next_token
    @tree.shift
  end

  def invalid_token_error token
    abort "invalid token " + token.class.to_s
  end

  def parse_tree
    while true
      token = next_token
      return nil if token.nil?
      if token.is_a?(IdentifierToken) and token.name == :':' then
        name = next_token
        body = next_token
        define_word name.name, body
      elsif token.is_a?(DoToken) then
        body = next_token
        abort "redefining entry point" if not @entry.nil?
        @entry = body
      else
        invalid_token_error token
      end
    end
  end

  def word name
    @words[name]
  end

  def word? name
    @words.has_key? name
  end

  def define_word name, body
    if not @words.has_key?(name) then
      @words[name] = body
    else
      abort "word " + name.to_s + " already defined"
    end
  end
end
