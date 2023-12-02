class Source
  class Line
    attr_reader :line_number, :first, :last, :value

    def initialize line_number, first, last, value
      @first = first
      @last = last
      @value = value
      @line_number = line_number
    end
  end

  def initialize string
    @string = string
  end

  def get_line_at position
    counter = 0
    @string.each_line.each_with_index { |line, i|
      if counter + line.length >= position then
        return Line.new i+1, counter, counter+line.length, line
      else
        counter += line.length
      end
    }
    abort "index out of bounds"
  end
end
