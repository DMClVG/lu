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

  attr_reader :string

  def initialize string
    @string = string
  end

  def get_lines_through a, b
    lines = []
    c = 0

    @string.each_line.each_with_index { |line, i|
      first = c
      last = c + line.length

      if not (last < a or first > b) then
        lines << Line.new(i+1, first, last, line)
      end

      c += line.length
    }
    lines
  end

  def get_line_at position
    counter = 0
    @string.each_line.each_with_index { |line, i|
      if counter + line.length > position then
        return Line.new i+1, counter, counter+line.length, line
      else
        counter += line.length
      end
    }
    abort "index out of bounds"
  end
end

class SourceWithPath < Source
  attr_reader :path
  def initialize string, path
    super string
    @path = path
  end

  def self.load_from_file path
    # TODO: error handling
    string = File.open(path).read
    SourceWithPath.new string, path
  end
end
