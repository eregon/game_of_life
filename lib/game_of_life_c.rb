require File.expand_path('../../ext/game_of_life_c', __FILE__)

class TrueClass
  def == o
    equal?(o) or o == 1
  end
end
class FalseClass
  def == o
    equal?(o) or o == 0
  end
end

class GameOfLife
  def initialize(width, height = width)
    case width
    when Array
      @height, @width = width.size, width.first.size
      @grid = width.map { |row| row.map { |i| i == 1 } }.flatten
    when String
      ary = width.lines.map { |line|
        line.chomp.chars.map { |v| (%w[x X].include? v) }
      }
      @height, @width = ary.size, ary.first.size
      @grid = ary.flatten
    else
      @width, @height = width, height
      @grid = Array.new(@height*@width) { rand(2) == 1 }
    end
    @size = @width*@height
  end

  def state= state
    @height, @width = state.size, state.first.size
    @size = @width*@height
    @false_ary = Array.new(@size) { false }
    @grid = state.map { |row| row.map { |i| i == 1 } }.flatten
  end

  # As written in README:
  # edges of game: just pretend that the board is folded onto itself, and the edges touch each other.
  # So 0 - 1 must be mapped to last, which ary[-1] does
  # But ary.size must be mapped to 0, so we can simply % it
  def [](x, y)
    @grid[(y % @height) * @width + (x % @width)]
  end

  def []=(x, y, v)
    @grid[(y % @height) * @width + (x % @width)] = v
  end

  def to_s
    @height.times.map { |y|
      @width.times.map { |x|
        @grid[y * @width + x] ? '#' : ' '
      }.join
    }.join("\n")
  end
end
