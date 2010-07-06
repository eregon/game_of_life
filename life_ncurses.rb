#
# This is a class to allow you to visualize your game of life with ncurses.
#
# howto
# if your class is called GameOfLife
#    LifeNcurses.new(GameOfLife.new(...))
# with ... the paramters that your initialize method takes
#
# this should show you the game of life evolving in your terminal
# there is a second optional parameter for the number of generations you want to see
#    LifeNcurses.new(GameOfLife.new(...),5)
# if you want to see only 5 generations

require 'rubygems'
require 'ffi-ncurses'

class LifeNcurses
  MARGIN = 1 # spaces from the border of the terminal
  include FFI::NCurses

  def initialize(game_of_life, sleep = 0.05)
    @sleep = sleep.to_f
    @stdscr = initscr
    cbreak
    @last_time = Time.now
    (1..1_000_000).each do |generation|
      clear
      display_title(generation)
      show game_of_life.evolve
    end
  rescue Interrupt
  ensure
    endwin
  end

  def show(state)
    state.each_with_index do |row, row_index|
      row.each_with_index do |col, col_index|
        mvwaddstr @stdscr, MARGIN+row_index, MARGIN+col_index, '#' if state[row_index][col_index] == 1
      end
    end
    refresh
    sleep @sleep
  end

  def display_title(generation)
    now = Time.now
    mvwaddstr @stdscr, 0, 1, "Game of life: Generation #{generation}, gps: #{(1/(now-@last_time)).to_i}"
    @last_time = now
  end

end

if __FILE__ == $0
  require './lib/game_of_life'
  DEFAULT_PATTERN = 'patterns/Gosper_glider_gun_static.txt'
  DEFAULT_SLEEP = 0.05
  if ARGV.delete '-h'
    puts "ruby #{$0} [pattern=#{DEFAULT_PATTERN}] [sleep_time=#{DEFAULT_SLEEP}]"
  else
    LifeNcurses.new(
      GameOfLife.new(
        IO.read(
          ARGV.shift || DEFAULT_PATTERN
        )
      ),
      ARGV.shift || DEFAULT_SLEEP
    )
  end
end
