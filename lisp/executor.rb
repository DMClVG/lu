def expr m, ret, env, node
	case node
	when ExpressionList
    m.push ExpressionExecutorObject.new(ret, env, node)
	when BindList
    # puts m.read_stack
    node.each { |id| 
      env.define id, m.pop
    }
    # puts m.read_stack
    m.push ret
	when BlockList
		m.push BlockObject.new(env, node)	
		m.push ret
	when Symbol
		if node.start_with? ":" then
      m.push m.symbol(node.to_s[1..node.length].to_sym)
		else
			m.push env.get node
		end
		m.push ret
	when String
		m.push StringObject.new node
		m.push ret
	when Integer
		m.push NumberObject.new node
		m.push ret
	else raise "Can't evaluate " + node.class.to_s
	end
end

class ExpressionExecutorObject
	def initialize ret, env, node
		@env = env
		@ret = ret
		@node = node
		@pc = node.length - 1
	end

	def onsend m
		if @pc == 0 then
			m.push @ret	
    elsif @pc < 0 then
      return
    end

    node = @node[@pc]
    @pc -= 1
    expr m, self, @env, node
	end
end

class EnvironmentObject
	def initialize
		@names = Hash.new
	end
	
	def get name
		val = @names[name]
		abort "undefined name " + name.to_s unless val 
		val
	end

	def define name, val
		@names[name] = val
	end
end

class BlockObject
	def initialize env, node
		@env = env
		@node = node
	end

	def node
		@node
	end

	def onsend m
		ret = m.pop
		m.push BlockExecutorObject.new ret, @env, self
	end
end

class BlockExecutorObject
	def initialize ret, env, block
		@ret = ret
		@env = env
		@block = block
    @node = block.node
		@pc = 0
	end

	def onsend m
		if @pc >= @node.length then
			#puts '- block exited -'
			m.push @ret
		else
			node = @node[@pc]
			@pc += 1
			expr m, self, @env, node
		end
    #if @pc == @node.length - 1 then
		#	#puts '- block exited -'
		#	node = @node[@pc]
		#	@pc += 1
		#	expr m, @ret, @env, node
    #else
		#	node = @node[@pc]
		#	@pc += 1
		#	expr m, self, @env, node
    #end
	end
end

parser = EsyParser.new code

tree = parser.parse
#ap tree

m = Esy.new 

env = EnvironmentObject.new
env.define :terminal, TerminalObject.new
env.define :halt, HaltObject.new
env.define :nil, NilObject.new
env.define :table, TableFactory.new
env.define :array, ArrayFactory.new

program = BlockObject.new env, tree

m.push HaltObject.new
m.push program
m.dosend 1

