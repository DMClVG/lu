
class Executor
  include Lexer

  class ExecutionException < StandardError;
    attr_reader :token
    def initialize token
      @token = token
    end
  end

  class UndefinedWordException < ExecutionException; end
  class StackUnderflowException < ExecutionException; end
  class BadTypeException < ExecutionException; end

  def assert_type type, x
    raise BadTypeException unless type.checks(x)
  end

  def initialize machine, environment
    @m = machine
    @env = environment
  end

  def execute_token token
    m = @m

    case token.value
    when String
      m.push token.value
    when Integer
      m.push token.value
    when Symbol
      begin
        case token.value
        when :'='
          if m.pop == m.pop then m.push 1 else m.push 0 end
        when :'<>'
          if m.pop != m.pop then m.push 1 else m.push 0 end
        when :'.s'
          puts " < " + m.read_stack + " > "
        when :'drop'
          m.pop
        when :'nip'
          m.swap
          m.pop
        when :'tuck'
          m.swap
          m.pick 1
        when :'dup'
          m.pick 0
        when :'over'
          m.pick 1
        when :'pick'
          n = m.pop
          m.pick n
        when :'swap'
          m.swap
        when :'rot'
          m.rot
        when :'-rot'
          m.rot
          m.rot
        when :'or'
          b, a = m.pop, m.pop
          if b != 0 or a != 0 then
            m.push 1
          else
            m.push 0
          end
        when :'and'
          b, a = m.pop, m.pop
          if b != 0 and a != 0 then
            m.push 1
          else
            m.push 0
          end
        when :'*'
          b, a = m.pop, m.pop
          m.push a * b
        when :'+'
          b, a = m.pop, m.pop
          m.push a + b
        when :'-'
          b, a = m.pop, m.pop
          m.push a - b
        when :'/'
          b, a = m.pop, m.pop
          m.push a / b
        when :'/mod'
          b, a = m.pop, m.pop
          m.push a % b
          m.push a / b
        when :'emit'
          c = m.pop
          print c.chr
        when :'abort'
          abort
        else
          raise UndefinedWordException.new token unless @env.words.key? token.value
          word = @env.words[token.value]
          execute_token word.body
        end
      rescue Sy::StackUnderflowException => e
        raise StackUnderflowException.new token
      end
    when ThenBlock
      if @m.pop != 0 then
        execute_token token.value.body
      end
    when ElseBlock
      if @m.pop == 0 then
        execute_token token.value.body
      end
    when RangeBlock
      b, a = m.pop, m.pop
      (a...b).each { |i|
        m.push i
        execute_token token.value.body
      }
    when TimesBlock
      n = m.pop
      n.times { execute_token token.value.body }
    when WhileBlock
      while_block = token.value
      loop do
        execute_token while_block.condition_body
        break unless m.pop == 1
        execute_token while_block.loop_body
      end
    when UntilBlock
      until_block = token.value
      loop do
        execute_token until_block.condition_body
        break if m.pop == 1
        execute_token until_block.loop_body
      end
    when ThenElseBlock
      if @m.pop != 0 then
        execute_token token.value.then_body
      else
        execute_token token.value.else_body
      end
    when Array
      token.value.each { |t| execute_token t }
    else
      if token.respond_to? :call then
        token.call @m, self
      else
        abort "unimplemented"
      end
    end
  end

  def execute
    execute_token @env.entry
  end
end
