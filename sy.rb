require_relative "lexer"
require_relative "env"
require "awesome_print"

class Sy
	def initialize
		@stack = Array.new
		@halted = false
    @trace = []
    @trace_enable = false
	end

  def equal? a, b
    a === b
  end

	def halt
		@halted = true
		#puts self.read_stack
	end

	def halted?
		@halted
	end

	def read_stack
    val = ""
		@stack.each { |e| val << e.to_s << " " }
    val.strip
	end

  def symbol name
    name
  end

	def pop
		o = @stack.pop
		if o == nil then
      raise RuntimeError, "stack underflow"
		else
			o
		end
	end

	def push o
		@stack << o
	end

  def swap
    x = pop
    y = pop
    push x
    push y
  end

  def rot
    x = pop
    y = pop
    z = pop
    push y
    push x
    push z
  end

  def unknown_message_error o, m
    abort(o.to_s + ": unknown message " + m.to_s)
  end

  def read_trace
		val = "\n== TRACE ==\n"
		@trace.each { |e| val << e.to_s << "\n" }
		val << "\n"
		val
  end
end

class Executor
  def initialize m, env
    @m = m
    @env = env
  end

  def execute_token token
    case token
    when String
      @m.push token
    when Integer
      @m.push token
    when IdentifierToken
      abort "undefined word " + token.name.to_s unless @env.word? token.name

      word = @env.words[token.name]
      execute_token word
    when BlockToken
      token = token.clone
      loop do
        t = token.shift
        break if t.nil?
        if t.is_a?(IdentifierToken) and t.name == :then then
          body = token.shift
          if @m.pop != 0 then
            execute_token body
          end
        elsif t.is_a?(IdentifierToken) and t.name == :else then
          body = token.shift
          if @m.pop == 0 then
            execute_token body
          end
        elsif t.is_a?(IdentifierToken) and t.name == :range then
          body = token.shift
          b = @m.pop
          a = @m.pop
          for i in a..b-1 do
            @m.push i
            execute_token body
          end
        else
          execute_token t
        end
      end
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

input = ARGV[0]
code = File.open(input).read

tree = Lexer.new(code).parse

env = Environment.new tree
env.parse_tree
analyzer = Analyzer.new env
analyzer.analyze

env.define_word :dup, lambda { |m, exec|
  v = m.pop
  m.push v
  m.push v
}
env.define_word :drop, lambda { |m, exec|
  m.pop
}
env.define_word :+, lambda { |m, exec|
  a, b = m.pop, m.pop
  m.push a+b
}
env.define_word :*, lambda { |m, exec|
  a, b = m.pop, m.pop
  m.push a*b
}
env.define_word :type, lambda { |m, exec|
  print m.pop
}
env.define_word :nl, lambda { |m, exec|
  puts ""
}

env.define_word :'=', lambda { |m, exec| if m.pop == m.pop then m.push 1 else m.push 0 end }
env.define_word :'<>', lambda { |m, exec| if m.pop != m.pop then m.push 1 else m.push 0 end }
env.define_word :'.s', lambda { |m, exec| puts "< " + m.read_stack + " >"}
env.define_word :swap, lambda { |m, exec| m.swap }

abort "no entry point defined in code" if env.entry.nil?

exec = Executor.new Sy.new, env
exec.execute
