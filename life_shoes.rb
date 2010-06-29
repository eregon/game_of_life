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
    @cells = Array.new(@height) { |y|
      Array.new(@width) { |x|
        rect 100+W*x, 50+W*y, W, W, :fill => white
      }
    }
    @initialized = true
  end

  def show_cells
    ## INSERT YOUR OWN CLASS WITH ITS ARGUMENTS HERE ##
    game = GameOfLife.new IO.read('patterns/glider.txt')
    @e = every 0.7 do |n|
      @n.text = "Generation: #{n}"
      life = game.evolve
      @initialized ||= initialize_cells(life)
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
  @n = para
end
