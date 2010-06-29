class Integer
  def to_b
    self == 1 ? true : false
  end
end

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

class GameOfLife
  def self.implementation
    Boolean
  end

  def initialize(width, height = width)
    case width
    when Array
      self.state = width
      @height, @width = @state.size, @state.first.size
    when String
      @state = width.lines.map { |line|
        line.chomp.chars.map { |v| (%w[x X].include? v) }
      }
      @height, @width = @state.size, @state.first.size
    else
      @width, @height = width, height
      @state = Array.new(height) { Array.new(width) { rand(2) == 1 }  }
    end
  end

  def state
    @state
  end

  def state= state
    @state = state.map { |row| row.map { |i| i == 1 } }
  end

  NEIGHBORS = [[1,0], [1,1], [0,1], [-1,1], [-1,0], [-1,-1], [0,-1], [1,-1]]
  def neighbors x, y
    NEIGHBORS.count { |dx, dy| self[x+dx, y+dy] }
  end

  def evolve
    @new_state = @state.map(&:dup)
    @state.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        @new_state[y][x] = cell.evolve( neighbors(x,y) )
      end
    end
    @state = @new_state
    state
  end

  # As written in README:
  # edges of game: just pretend that the board is folded onto itself, and the edges touch each other.
  # So 0 - 1 must be mapped to last, which ary[-1] does
  # But ary.size must be mapped to 0, so we can simply % it
  def [](x, y)
    @state[y % @height][x % @width]
  end

  def []=(x, y, v)
    @state[y % @height][x % @width] = (v == 1)
  end

  def to_s
    @state.map(&:join).join("\n")
  end
end

if __FILE__ == $0
  game = GameOfLife.new IO.read('patterns/glider.txt')
  100.times {
    game.evolve
    # puts "\n"*10
    puts game
    sleep(0.3)
  }
end
