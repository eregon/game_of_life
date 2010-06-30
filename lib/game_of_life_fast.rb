module Boolean
  def to_i
    self ? 1 : 0
  end

  def == other
    (Boolean === other and other == self) or self.to_i == other
  end

  def evolve(neighbors)
    if self
      (2..3).include? neighbors
    else
      neighbors == 3
    end
  end
end
class TrueClass
  include Boolean
  def to_s
    '#'
  end
end
class FalseClass
  include Boolean
  def to_s
    ' '
  end
end

class Grid
  attr_reader :grid, :width, :height
  def initialize(ary, width, height)
    @height, @width = height, width
    @grid = ary
  end

  def wrap(x, y)
    x += @width if x < 0
    x -= @width if x >= @width
    y += @height if y < 0
    y -= @height if y >= @height
    [x, y]
  end

  def [](x, y)
    @grid[y * @width + x]
  end
  def []=(x, y, v)
    @grid[y * @width + x] = v
  end

  def to_a
    Array.new(@height) { |y| Array.new(@width) { |x| self[x, y] } }
  end
end

class GameOfLife
  def self.implementation
    "Fast"
  end

  def initialize(width, height = width)
    case width
    when Array
      @height, @width = width.size, width.first.size
      @grid = Grid.new(width.map { |row| row.map { |i| i == 1 } }.flatten, @width, @height)
    when String
      ary = width.lines.map { |line|
        line.chomp.chars.map { |v| (%w[x X].include? v) }
      }
      @height, @width = ary.size, ary.first.size
      @grid = Grid.new(ary.flatten, @width, @height)
    else
      @width, @height = width, height
      @grid = Grid.new(Array.new(@height*@width) { rand(2) == 1 }, @width, @height)
    end
    @size = @width*@height
    @neighbors = [1, -@width+1, -@width, -@width-1, -1, @width-1, @width, @width+1]
  end

  def state
    @grid.to_a
  end
  def state= state
    @grid = Grid.new(state.map { |row| row.map { |i| i == 1 } }.flatten, state.first.size, state.size)
  end

  def neighbors i
    @neighbors.count { |delta|
      @grid.grid[(i+delta) - @size] # - @size is a bit faster than % @size (~4%)
    }
  end

  def evolve
    @new_grid = Grid.new(Array.new(@height*@width) { false }, @width, @height)
    @size.times { |i|
      @new_grid.grid[i] = true if @grid.grid[i].evolve( neighbors(i) )
    }
    @grid = @new_grid
    state
  end

  # As written in README:
  # edges of game: just pretend that the board is folded onto itself, and the edges touch each other.
  # So 0 - 1 must be mapped to last, which ary[-1] does
  # But ary.size must be mapped to 0, so we can simply % it
  def [](x, y)
    @grid[*@grid.wrap(x, y)]
  end

  def []=(x, y, v)
    @grid[*@grid.wrap(x, y)] = v
  end

  def to_s
    s = ""
    @height.times.map { |y|
      @width.times.map { |x|
        @grid[x, y].to_s
      }.join
    }.join("\n")
  end
end
