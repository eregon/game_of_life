class Cell
  attr_reader :alive
  alias :alive? :alive
  def initialize(alive = true)
    alive = (alive == 1) if alive.is_a? Integer
    @alive = alive
  end

  def evolve(neighbours)
    Cell.new(if @alive
      (2..3).include? neighbours.count(&:alive?)
    else
      neighbours.count(&:alive?) == 3
    end)
  end

  def to_i
    @alive ? 1 : 0
  end
end

class GameOfLife
  def initialize(width, height = width)
    @width, @height = width, height
    @state = Array.new(height) { Array.new(width) { Cell.new }  }
  end

  def state
    @state.map { |row| row.map { |cell| cell.to_i } }
  end

  def state= state
    @state = state.map { |row| row.map { |i| Cell.new(i) } }
  end

  def neighbours cell_x, cell_y
    [[1,0], [1,1], [0,1], [-1,1], [-1,0], [-1,-1], [0,-1], [1,-1]].map { |dx, dy|
      # As written in README:
      # edges of game: just pretend that the board is folded onto itself, and the edges touch each other.
      # So 0 - 1 must be mapped to last, which ary[-1] does
      # But ary.size must be mapped to 0, so we can simply % it
      @state[(cell_y + dy) % @height][(cell_x + dx) % @width]
    }
  end

  def evolve
    @new_state = @state.map(&:dup)
    @state.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        @new_state[i][j] = cell.evolve( neighbours(j,i) )
      end
    end
    @state = @new_state
    state
  end
end
