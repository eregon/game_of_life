require File.expand_path('../module', __FILE__)

class Cell
  ALIVE, DEAD = '#', ' '
  attr_reader :alive?
  def initialize(alive)
    alive = (alive == 1) if alive.is_a? Integer
    @alive = alive
    @future = :unknown
  end

  def figure_evolution(neighbors)
    @future = if @alive
      (2..3).include? neighbors
    else
      neighbors == 3
    end
  end

  def evolve!
    @alive = @future
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
    "State"
  end

  def initialize(width, height = width)
    self.state = case width
    when Array
      width
    when String
      width.lines.map { |line| line.chomp.chars.map { |v| %w[x X].include? v } }
    else
      Array.new(height) { Array.new(width) { rand(2) } }
    end
  end

  attr_reader :state
  def state= state
    @height, @width = state.size, state.first.size
    @state = state.map { |row| row.map { |i| Cell.new(i) } }
  end

  NEIGHBORS = [[1,0], [1,1], [0,1], [-1,1], [-1,0], [-1,-1], [0,-1], [1,-1]]
  def neighbors x, y
    NEIGHBORS.count { |dx, dy| self[x+dx, y+dy].alive? }
  end

  def evolve
    @state.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        cell.figure_evolution neighbors(x,y)
      end
    end
    @state.each { |row| row.each { |cell| cell.evolve! } }
  end

  def [](x, y)
    @state[y % @height][x % @width]
  end

  def to_s
    @state.map(&:join).join("\n")
  end
end
