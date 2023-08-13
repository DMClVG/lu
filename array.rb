require_relative "utils"

class ArrayFactory
  def onsend m
    ret = m.pop
    msg = m.pop
    case msg
    when :new
      m.push ArrayObject.new
      m.push ret 
    end
  end
end

class ArrayIteratorObject
  def initialize ret, array, closure
    @ret = ret
    @array = array
    @closure = closure
    @i = 0
  end

  def onsend m
    if @i < @array.length then
      @i += 1
      m.push @array[@i - 1]
      m.push self
      m.push @closure
    else
      m.push @ret
    end
  end
end
class ArrayObject < Array
  def onsend m
    ret = m.pop
    msg = m.pop
    case msg
    when :get
      idx = tointeger m.pop
      m.push self[idx]
      m.push ret
    when :set
      idx = tointeger m.pop
      self[idx] = m.pop
      m.push ret
    when :each
      closure = m.pop
      m.push ArrayIteratorObject.new ret, self, closure
    end
  end
end
