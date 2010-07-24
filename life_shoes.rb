#
# This is a Shoes app to visualize your game of life.
#

## REQUIRE YOUR OWN CLASS HERE ##
require 'lib/game_of_life'
W = 10 # cell width

Shoes.app :title => 'Game of Life'do
  background khaki
  stroke pink

  def initialize_cells(life)
    @height = life.size
    @width = life.first.size
    Array.new(@height) { |y|
      Array.new(@width) { |x|
        rect 100+W*x, 50+W*y, W, W, :fill => white
      }
    }
  end

  def show_cells
    ## INSERT YOUR OWN CLASS WITH ITS ARGUMENTS HERE ##
    @game ||= GameOfLife.load_pattern('patterns/Gosper_glider_gun.txt')
    @n ||= 0
    @e = every @speed.text.to_f do
      @generation.text = "Generation: #{@n += 1}"
      life = @game.evolve
      @cells ||= initialize_cells(life)
      @height.times{ |y|
        @width.times{ |x|
          @cells[y][x].style :fill => (life[y][x] == 0 ? white : green)
        }
      }
    end
  end

  gb = stack
  para link('start') { gb.clear { show_cells } }
  para link('stop') { @e.stop }
  @generation = para
  @speed = para '0.5'
  para link('slower') { @e.stop; @speed.text = @speed.text.to_f+0.1; gb.clear { show_cells } }
  para link('faster') { @e.stop; @speed.text = @speed.text.to_f-0.1; gb.clear { show_cells } }
end
