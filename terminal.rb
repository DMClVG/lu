class TerminalObject
	def onsend m
		ret = m.pop
		msg = m.pop

		case msg
		when :put
			print m.pop
		when :putln
			puts m.pop
		when :nl
			print "\n"	
    else abort "unknown message " + msg.to_s
		end

		m.push ret
	end
end
