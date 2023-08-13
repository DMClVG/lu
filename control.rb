
class HaltObject
	def onsend m
		puts "- esy halted -"
		m.halt
		abort 
	end
end

class RelayObject
	def onsend m
		ret = m.pop
		m.push ret
	end
end

class FalseObject
	def to_s
		"false"
	end

	def onsend m
			ret = m.pop
			method = m.pop

			case method
			when :then
				closure = m.pop
				m.push ret
			when :else
				closure = m.pop
				m.push ret
				m.push closure
			end
	end
end

class TrueObject
	def to_s
		"true"
	end

	def onsend m
			ret = m.pop
			method = m.pop

			case method
			when :then
				closure = m.pop
				m.push ret
				m.push closure
			when :else
				closure = m.pop
				m.push ret
			end
	end
end
