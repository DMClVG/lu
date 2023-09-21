require_relative "base"
require_relative "control"
require_relative "debug"
require_relative "terminal"
require_relative "store"
require_relative "string"
require_relative "math"
require_relative "table"
require_relative "array"
require_relative "forth/parser"
require_relative "forth/executor"
require "awesome_print"

class Esy 
	def initialize 
		@stack = Array.new
		@halted = false
    @trace = []
    @trace_enable = false
	end

  def equals? a, b
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
		val = "\n== STACK ==\n"
    val << "(SIZE=" << @stack.length.to_s << ")"
		@stack.each { |e| val << e.to_s << "\n" }
		val << "\n"
		val
	end

  def symbol name
    name
  end

	def pop
		o = @stack.pop
		if o == nil then
			abort "stack underflow"
		else
			o	
		end
	end

	def push o
		@stack << o
	end

  def read_trace
		val = "\n== TRACE ==\n"
		@trace.each { |e| val << e.to_s << "\n" }
		val << "\n"
		val
  end

	def dosend n
    loop do
      receiver = self.pop
      break if receiver == nil
      @trace << receiver.to_s if @trace_enable
      begin
        receiver.onsend self
      rescue Exception => e
        puts read_trace if @trace_enable
        halt
        raise e
      end
      # puts "sent to " + receiver.to_s
    end
	end
end

class RubyObject
	def initialize &fun
		@fun = fun
	end

	def onsend m
		ret = m.pop
		obj = @fun.call m	

		m.push obj
		m.push ret
	end
end


input = ARGV[0]
code = File.open(input).read

tree = Forth::Parser.new(code).parse

m = Esy.new

env = Forth::EnvironmentObject.new
env.define :terminal, TerminalObject.new
env.define :halt, HaltObject.new
env.define :nil, NilObject.new
env.define :table, TableFactory.new
env.define :array, ArrayFactory.new
env.define :swap, SwapObject.new
env.define :rot, RotObject.new

m.push HaltObject.new
m.push Forth::BlockObject.new env, tree
m.dosend 0

