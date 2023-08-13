class CharacterObject
	def initialize char
		@char = char
	end
	def to_s
		@char
	end
	def onsend m
		ret = m.pop
		m.push ret
		m.dosend 0
	end
end


class StringObject
	def initialize s
		@s = s
	end
	def to_s
		@s
	end
	def onsend m
		ret = m.pop
		msg = m.pop	
		#TODO
		case msg
		when "char-at"
			idx = tointeger m.pop
			m.push CharacterObject.new(@s[idx])
		else abort "unknown message"
		end

		m.push ret
	end
end
