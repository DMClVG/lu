class DebuggerObject
	def onsend m
		puts m.read_stack

		ret = m.pop

		puts "DEBUG : " +  m.pop.to_s

		m.push ret
	end
end
