module SymbolObjectOnSend 
  def onsend m
    ret = m.pop
    msg = m.pop
    case msg
    when :equal?
      if m.pop == self then
        m.push TrueObject.new
        m.push ret
      else
        m.push FalseObject.new
        m.push ret
      end
    else abort "unknown message " + msg.to_s
    end
  end
end
Symbol.send(:include, SymbolObjectOnSend)

class SwapObject
  def onsend m
    ret = m.pop

    b = m.pop
    a = m.pop 

    m.push b
    m.push a

    m.push ret
  end
end

class RotObject
  def onsend m
    ret = m.pop

    a = m.pop
    b = m.pop
    c = m.pop 

    m.push b
    m.push a
    m.push c

    m.push ret
  end
end

class NilObject
	def onsend m
		abort("tried to send to a nil object")
	end
end

