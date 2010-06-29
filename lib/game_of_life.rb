# encoding: utf-8
if RUBY_VERSION < "1.9.2"
  # Using a local copy of `backports` as Shoes can not access rubygems
  $: << File.expand_path("../backports-1.18.1/lib", __FILE__)
  require "backports"
end

require_relative 'module'

class Cell
  ALIVE, DEAD = '#', ' ' # O· # ○
  attr_reader :alive?
  def initialize(alive = rand(2))
    alive = (alive == 1) if alive.is_a? Integer
    @alive = alive
  end

  def evolve(neighbors)
    Cell.new(if alive?
      (2..3).include? neighbors
    else
      neighbors == 3
    end)
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

  def state
    @state
  end

  def state= state
    @state = state.map { |row| row.map { |i| Cell.new(i) } }
  end

  DIRECTIONS = [[1,0], [1,1], [0,1], [-1,1], [-1,0], [-1,-1], [0,-1], [1,-1]]
  def neighbors x, y
    DIRECTIONS.count { |dx, dy| self[x+dx, y+dy].alive? }
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
    @state[y % @height][x % @width] = Cell.new(v)
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
