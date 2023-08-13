require_relative "utils"

class TableFactory 
	def onsend m
		ret = m.pop
		msg = m.pop

		case msg
		when :new
			m.push TableObject.new
			m.push ret
		else abort "unknown message"
		end
	end
end

class TableObject
	def initialize
		@hash = Hash.new
	end
	def onsend m
		ret = m.pop
		msg = m.pop

		case msg
		when  :set
			name = m.pop
			value = m.pop
			@hash[name.name] = value
			m.push ret
		when :get
			name = m.pop
			m.push @hash[name.name]
			m.push ret
		else abort "unknown message"
		end
	end
end
