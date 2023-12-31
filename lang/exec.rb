
require "tty-cursor"
require "tty-screen"

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
    @cursor = TTY::Cursor
    @size = TTY::Screen.size
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

        when :'sqrt'
          m.push Math.sqrt(m.pop)
        when :'emit'
          c = m.pop
          print c.chr
        when :'goto'
          y,x = m.pop, m.pop
          print @cursor.move_to x, y
        when :'cols'
          m.push TTY::Screen.size[1]
        when :'rows'
          m.push TTY::Screen.size[0]
        when :'clear-line'
          @cursor.clear_line
        when :'hide'
          print @cursor.hide
        when :'clear'
          print @cursor.clear_screen
        when :sleep
          ms = m.pop
          sleep ms/1000.0
        when :'chars'
          s = m.pop
          m.push s.chars
        when :length
          m.push m.pop.length
        when :'drop'
          m.pop
        when :'nip'
          m.swap
          m.pop
        when :'wrap'
          count = m.pop
          tuple = Array.new
          count.times {
            tuple.unshift m.pop
          }
          m.push tuple
        when :'unwrap'
          top = m.pop
          if top.respond_to?(:each) then
            top.each { |v| m.push v }
          else
            m.push top # do nothing :)
          end
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
        when :'>'
          b, a = m.pop, m.pop
          if a > b then
            m.push 1
          else
            m.push 0
          end
        when :'<'
          b, a = m.pop, m.pop
          if a < b then
            m.push 1
          else
            m.push 0
          end
        when :'>='
          b, a = m.pop, m.pop
          if a >= b then
            m.push 1
          else
            m.push 0
          end
        when :'<='
          b, a = m.pop, m.pop
          if a <= b then
            m.push 1
          else
            m.push 0
          end
        when :'mod'
          b, a = m.pop, m.pop
          m.push a % b
        when :'/mod'
          b, a = m.pop, m.pop
          m.push a % b
          m.push a / b
        when :'abort'
          abort
        else
          if @env.words.key? token.value
            word = @env.words[token.value]
            execute_token word.body
          else
            raise UndefinedWordException.new token
          end
        end
      rescue Sy::StackUnderflowException => e
        raise StackUnderflowException.new token
      end
    when WrapBlock
      stack_depth_before = m.stack_depth
      execute_token token.value.body
      stack_depth_after = m.stack_depth

      elements = [0, stack_depth_after - stack_depth_before].max

      if elements <= 1 then
        # do nothing
      else
        wrap = Array.new
        elements.times {
          wrap.unshift m.pop
        }
        m.push wrap
      end
    when ThenBlock
      if @m.pop != 0 then
        execute_token token.value.body
      end
    when ElseBlock
      if @m.pop == 0 then
        execute_token token.value.body
      end
    when LoopBlock
      loop do
        execute_token token.value.body
      end
    when TimesBlock
      n = m.pop
      n.times { execute_token token.value.body }
    when EachBlock
      it = m.pop
      abort "not iterable" unless it.respond_to?(:each)
      it.each { |e|
        m.push e
        execute_token token.value.body
      }
    when MapBlock
      it = m.pop
      abort "not mappable" unless it.respond_to?(:map)
      m.push (it.map { |e|
        m.push e
        execute_token token.value.body
        m.pop
      })
    when FoldLeftBlock
      acc = m.pop
      it = m.pop
      abort "not iterator" unless it.respond_to?(:each)
      it.each { |x|
        m.push acc
        m.push x
        execute_token token.value.body
        acc = m.pop
      }
    when FoldRightBlock
      acc = m.pop
      it = m.pop
      abort "not iterator" unless it.respond_to?(:reverse_each)
      it.reverse_each { |x|
        m.push acc
        m.push x
        execute_token token.value.body
        acc = m.pop
      }
    when WhileBlock
      while_block = token.value
      loop do
        execute_token while_block.condition_body
        break unless m.pop == 1
        execute_token while_block.loop_body
      end
    when MakeBlock
      res = Hash.new
      fields = token.value.body.value
      fields.reverse.each { |name|
        abort "expected symbol" unless name.value.is_a?(Symbol)
        res[name.value] = m.pop
      }
      m.push res
    when AccessSymbol
      top = m.pop
      m.push top[token.value.name]
    when UntilBlock
      until_block = token.value
      loop do
        execute_token until_block.condition_body
        break if m.pop == 1
        execute_token until_block.loop_body
      end
    when ChainBlock
      v = m.pop
      token.value.body.value.each { |part|
        m.push v
        execute_token part
      }
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
    execute_token @env.entry.body
  end
end
