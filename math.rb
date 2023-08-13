class CounterObject
  def initialize 
  end

  def onsend m
    
    m.push ret
  end
end

class NumberObject
	def initialize n
		@n = n
	end
	def to_s
		@n.to_s
	end
	def to_i
		@n
	end

	def onsend m
		ret = m.pop
		msg = m.pop
		res = nil

		case msg
    when :negative?
      if @n < 0 then
        res = TrueObject.new
      else
        res = FalseObject.new
      end
    when :positive?
      if @n > 0 then
        res = TrueObject.new
      else
        res = FalseObject.new
      end
		when :zero?
			if @n == 0 then
				res = TrueObject.new
			else
				res = FalseObject.new
			end
		when :succ
			res = NumberObject.new @n + 1
		when :pred
			res = NumberObject.new @n - 1
		else abort
		end

		m.push res
		m.push ret
	end
end
