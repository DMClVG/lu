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

class NilObject
	def onsend m
		abort("tried to send to a nil object")
	end
end

