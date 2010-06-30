class Integer
  def evolve(neighbors)
    evolution = if self == 1
      (2..3).include? neighbors
    else
      neighbors == 3
    end
    evolution ? 1 : 0
  end
end

class GameOfLife
  def self.implementation
    Integer
  end

  def initialize(width, height = width)
    case width
    when Array
      self.state = width
      @height, @width = @state.size, @state.first.size
    when String
      @state = width.lines.map { |line|
        line.chomp.chars.map { |v| (%w[x X].include? v) ? 1 : 0 }
      }
      @height, @width = @state.size, @state.first.size
    else
      @width, @height = width, height
      @state = Array.new(height) { Array.new(width) { rand(2) }  }
    end
  end

  attr_accessor :state

  NEIGHBORS = [[1,0], [1,1], [0,1], [-1,1], [-1,0], [-1,-1], [0,-1], [1,-1]]
  def neighbors x, y
    NEIGHBORS.count { |dx, dy| self[x+dx, y+dy] == 1 }
  end

  def evolve
    @new_state = @state.map(&:dup)
    @state.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        @new_state[y][x] = cell.evolve( neighbors(x,y) )
      end
    end
    @state = @new_state
  end

  # As written in README:
  # edges of game: just pretend that the board is folded onto itself, and the edges touch each other.
  # So 0 - 1 must be mapped to last, which ary[-1] does
  # But ary.size must be mapped to 0, so we can simply % it
  def [](x, y)
    @state[y % @height][x % @width]
  end

  def []=(x, y, v)
    @state[y % @height][x % @width] = v
  end

  def to_s
    @state.map { |row| row.map { |i| i == 1 ? '#' : ' ' }.join }.join("\n")
  end
end
