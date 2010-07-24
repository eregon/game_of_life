#
# This is a Shoes app to visualize your game of life.
#

## REQUIRE YOUR OWN CLASS HERE ##
require 'lib/game_of_life'
CELL_WIDTH = 10
LEFT_MARGIN = 100
TOP_MARGIN = 75

Shoes.app :title => 'Game of Life'do
  CELL_DEAD, CELL_WAS_ALIVE, CELL_ALIVE = white, lightblue, darkblue

  background khaki
  stroke white

  def initialize_cells
    Array.new(@height) { |y|
      Array.new(@width) { |x|
        rect LEFT_MARGIN+CELL_WIDTH*x, TOP_MARGIN+CELL_WIDTH*y, CELL_WIDTH, CELL_WIDTH, :fill => CELL_DEAD
      }
    }
  end

  def display_title
    @generation.text = "Generation: #{@n += 1}"
    now = Time.now
    @real_fps.text = (1/(now-@last_time)).to_i
    @last_time = now
  end

  def show_cells
    @last_time = Time.now
    @animation = animate(@fps.text.to_i) do
      display_title

      last_life = @game.state
      life = @game.evolve

      @height.times{ |y|
        @width.times{ |x|
          color = (life[y][x] == 1 ? CELL_ALIVE : (last_life[y][x] == 1 ? CELL_WAS_ALIVE : CELL_DEAD))
          #color = (life[y][x] == 1 ? CELL_ALIVE : CELL_DEAD)
          @cells[y][x].style :fill => color unless @cells[y][x].style[:fill] == color
        }
      }
    end
  end

  def start
    show_cells
  end
  def stop
    @animation.stop
  end

  @game = GameOfLife.load_pattern('patterns/glider.txt')
  @height = @game.state.size
  @width = @game.state.first.size
  @n = 0
  @cells = initialize_cells

  stack do
    flow do
      para link('Start') { start }
      para link('Stop') { stop }
      @generation = para
    end

    flow do
      para link('slower') { stop; @fps.text = @fps.text.to_i-1; start }
      para 'gps: '
      @fps = para '5'
      para link('faster') { stop; @fps.text = @fps.text.to_i+1; start }
      para 'real fps: '
      @real_fps = para
    end

    @note = para "notes"
  end

  start
end
