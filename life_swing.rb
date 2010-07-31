#!/usr/bin/env jruby

require './lib/game_of_life'

include Java

class LifeJRuby < javax.swing.JFrame
  CELL_SIZE = 5
  def initialize(game, sleep = 0)
    super("Game Of Life with JRuby")
    add MyPanel.new(game)
    resize game.width*CELL_SIZE, (game.height+5)*CELL_SIZE
    show

    last_time = Time.now
    (1..1_000_000).each do |generation|
      game.evolve

      now = Time.now
      self.title = "Game Of Life: Generation: #{generation}, gps: #{(1/(now-last_time)).to_i}"
      last_time = now

      repaint
      sleep sleep
    end
  end
end

class MyPanel < javax.swing.JPanel
  import java.awt
  CELL_SIZE = LifeJRuby::CELL_SIZE
  def initialize(game)
    super()
    @game = game
  end

  def paintComponent graphics
    @game.state.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        graphics.color = cell == 1 ? Color::BLACK : Color::WHITE
        graphics.fill_rect x*CELL_SIZE, y*CELL_SIZE, CELL_SIZE-1, CELL_SIZE-1
      end
    end
  end
end

game = GameOfLife.load_pattern(ARGV.shift || 'patterns/Gosper_glider_gun_huge.txt')
if size = ARGV.find { |arg| /^\d+(x|\*)\d+$/ === arg }
  w, h = ARGV.delete(size).split(/x|\*/).map(&:to_i)
  game = game.enlarge(w/2-game.width/2,h/2-game.height/2,w,h)
end

LifeJRuby.new(game, ARGV.shift || 0)
