require "awesome_print"

class Sy

  class StackUnderflowException < StandardError; end

	def initialize
		@stack = Array.new
		@halted = false
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
      raise StackUnderflowException.new
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

  def pick n
    x = peek n
    raise StackUnderflowException.new if x.nil?
    push x
  end

  def peek n
    return nil if n >= @stack.length
    @stack[-n-1]
  end
end
