require 'spec_helper'

describe "GameOfLife (Spaceships)" do
  let(:glider) {
    [load_pattern('glider'), 4, [1, 1]]
  }

  let(:lightweight_spaceship) {
    [load_pattern('lightweight_spaceship'), 4, [2, 0]]
  }

  [:glider, :lightweight_spaceship].each do |spaceship|
    it "#{spaceship} should fly" do
      spaceship, period, advance = send(spaceship)
      advance_x, advance_y = advance
      game = GameOfLife.new(spaceship.dup)
      period.times { game.evolve }
      spaceship_moved = Array.new(spaceship.size) { |y|
        Array.new(spaceship.first.size) { |x|
          spaceship[y-advance_y][x-advance_x]
        }
      }
      game.state.should == spaceship_moved
    end
  end
end
