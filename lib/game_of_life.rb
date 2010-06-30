if RUBY_VERSION < "1.9.2"
  # Using a local copy of `backports` as Shoes can not access rubygems
  $: << File.expand_path("../backports-1.18.1/lib", __FILE__)
  require "backports"
end

unless defined? GameOfLife
  require File.expand_path("../game_of_life_" + "integer", __FILE__)
end

if __FILE__ == $0
  game = GameOfLife.new IO.read('patterns/Gosper_glider_gun.txt')
  100.times {
    game.evolve
    puts game
    sleep(0.3)
  }
end
