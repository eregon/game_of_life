#
# This is a simple visualisation using Chingu
# A more complete one would just be ridiculous to the awesome example they give
#

require 'gosu'
require 'chingu'

require './lib/game_of_life'

class Main < Chingu::Window
  CELL_SIZE = 5
  attr_reader :game, :sleep
  def initialize(game, sleep)
    @height, @width = game.state.size*CELL_SIZE, game.state.first.size*CELL_SIZE
    super(@width, @height, false)
    self.input = { :esc => :exit }
    push_game_state(GameOfLifeState.new(game, sleep))
  end

  def draw
    super and fill_rect([0, 0, @width, @height], 0xffffffff, -1)
  end
end

class GameOfLifeState < Chingu::GameState
  CELL_SIZE = Main::CELL_SIZE
  TIME_DELTA = 0.01
  def initialize(game, sleep)
    super()
    @game, @sleep = game, sleep.to_f
    @generation = 0
    @last_time = Time.now
    @running = true
    self.input = {
      :j => lambda { @sleep -= TIME_DELTA if @sleep > TIME_DELTA }, # faster
      :k => lambda { @sleep += TIME_DELTA }, # slower
      :l => lambda { @running = !@running } # pause
    }
  end

  def update
    super
    if @running
      now = Time.now
      @caption = "Game Of Life: Generation: #{@generation += 1}, gps: #{(1/(now-@last_time)).to_i}"
      @last_time = now
      @game.evolve
    end
  end

  def draw
    super()
    $window.caption = @caption
    @game.state.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        $window.fill_rect([x*CELL_SIZE, y*CELL_SIZE, CELL_SIZE-1, CELL_SIZE-1], 0xff0000aa) if cell == 1
        # $window.draw_circle(x*CELL_SIZE, y*CELL_SIZE, CELL_SIZE/2, 0xff0000aa) if cell == 1
      end
    end
    sleep @sleep
  end
end

if __FILE__ == $0
  DEFAULT_SLEEP = 0
  DEFAULT_PATTERN = 'patterns/Gosper_glider_gun_huge.txt'
  game = GameOfLife.load_pattern(ARGV.shift || DEFAULT_PATTERN)
  if size = ARGV.find { |arg| /^\d+(x|\*)\d+$/ === arg }
    w, h = ARGV.delete(size).split(/x|\*/).map(&:to_i)
    game = game.enlarge(w/2-game.width/2,h/2-game.height/2,w,h)
  end
  Main.new(game, ARGV.shift || DEFAULT_SLEEP).show
end
