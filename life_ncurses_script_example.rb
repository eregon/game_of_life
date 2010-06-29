# require your game of life class
require './lib/game_of_life'
require './life_ncurses'

# Use your own GameOfLife class, giving it the parameters you selected.
LifeNcurses.new(GameOfLife.new(IO.read('patterns/Gosper_glider_gun.txt')))
