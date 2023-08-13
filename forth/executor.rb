
module Forth
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

  class BlockExecutorObject
    def initialize ret, env, block
      @ret = ret
      @env = env
      @block = block
      @i = 0
    end
    def onsend m
      if @i >= @block.length then
        m.push @ret
        return
      end
      node = @block[@i] 
      case node
      when DoNode
        # execute what is on stack
      when HereNode
        m.push self
        m.push self
      when BlockNode
        m.push BlockObject.new @env, node
        m.push self
      when BindNode
        @env.define node.name, m.pop
        m.push self
      when NameNode
        m.push @env.get node.name
        m.push self
      when String
        m.push StringObject.new node
        m.push self
      when Integer
        m.push NumberObject.new node
        m.push self
      when Symbol
        m.push m.symbol node
        m.push self
      else abort node.class.to_s
      end
      @i += 1
    end
  end

  class BlockObject
    def initialize env, block
      @env = env
      @block = block
    end
    def onsend m
      ret = m.pop
      m.push BlockExecutorObject.new ret, @env, @block
    end
  end
end
