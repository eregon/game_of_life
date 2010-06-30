raise "Need Ruby 1.9 because it depends on Fiber" if RUBY_VERSION < '1.9'

require_relative 'module'

# This is largely inspired by Daniel Moore's solution to his own "Game of Life" Ruby Quiz
# The solution use abuse of Fiber, and is really interesting (but do not expect it to be fast)
# I commented it a little, because Fiber is not so easy to understand

class Cell < Fiber
  ALIVE, DEAD = '#', ' '
  attr_reader :alive?

  def initialize(alive = rand(2))
    alive = (alive == 1) if alive.is_a? Integer

    super() do # So this is Fiber.new { }
      loop do
        # First Fiber.yield: wait for caller to give neighbors
        # Here the caller has to give the number of alive neighbors as an argument to #resume
        neighbors = Fiber.yield(alive)

        alive = if alive
          (2..3) === neighbors
        else
          3 == neighbors
        end

        # Second Fiber.yield: update @alive
        # This simply update `@alive` to `alive`, and is #resume in #evolve
        Fiber.yield(alive)
      end
    end

    # We go until the first Fiber.yield
    # The return value is `alive`, which is what we want for `@alive`
    @alive = resume
  end

  alias :neighbors= :resume

  def evolve
    @alive = resume
  end

  def == other
    (Cell === other and other.alive? == @alive) or self.to_i == other
  end

  def to_i
    @alive ? 1 : 0
  end

  def to_s
    @alive ? ALIVE : DEAD
  end
end

class GameOfLife
  def self.implementation
    Fiber
  end

  def initialize(width, height = width)
    case width
    when Array
      self.state = width
      @height, @width = @state.size, @state.first.size
    when String
      @state = width.lines.map { |line|
        line.chomp.chars.map { |v| Cell.new(%w[x X].include? v) }
      }
      @height, @width = @state.size, @state.first.size
    else
      @width, @height = width, height
      @state = Array.new(height) { Array.new(width) { Cell.new }  }
    end
  end

  attr_reader :state
  def state= state
    @state = state.map { |row| row.map { |i| Cell.new(i) } }
  end

  NEIGHBORS = [[1,0], [1,1], [0,1], [-1,1], [-1,0], [-1,-1], [0,-1], [1,-1]]
  def alive_neighbors x, y
    NEIGHBORS.count { |dx, dy| self[x+dx, y+dy].alive? }
  end

  def evolve
    @state.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        cell.neighbors = alive_neighbors(x, y)
      end
    end
    @state.each { |row| row.each { |cell| cell.evolve } }
  end

  # As written in README:
  # edges of game: just pretend that the board is folded onto itself, and the edges touch each other.
  # So 0 - 1 must be mapped to last, which ary[-1] does
  # But ary.size must be mapped to 0, so we can simply % it
  def [](x, y)
    @state[y % @height][x % @width]
  end

  def []=(x, y, v)
    @state[y % @height][x % @width] = Cell.new(v)
  end

  def to_s
    @state.map(&:join).join("\n")
  end
end
