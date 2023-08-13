class StoreObject
	def initialize
		@val = NilObject.new
	end

	def	dosend m
		ret = m.pop
		msg = m.pop

		case msg.name
		when "set" 
			@val = m.pop	
			m.push ret 
			m.dosend 0
		when "get"
			m.push @val
			m.push ret
			m.dosend 1
		end	
	end
end

