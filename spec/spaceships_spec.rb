require 'spec_helper'

describe "GameOfLife (Spaceships)" do
  let(:glider) {
    [GameOfLife.load_pattern('glider'), 4, [1, 1]]
  }

  let(:lightweight_spaceship) {
    [GameOfLife.load_pattern('lightweight_spaceship'), 4, [2, 0]]
  }

  [:glider, :lightweight_spaceship].each do |spaceship|
    it "Spaceship should fly" do
      game, period, (advance_x,advance_y) = send(spaceship)
      game.enlarge(0, 0, game.width+period, game.height+period).surround
      spaceship = game.state
      period.times { game.evolve }
      spaceship_moved = Array.new(game.height) { |y|
        Array.new(game.width) { |x|
          spaceship[y-advance_y][x-advance_x]
        }
      }
      game.state.should == spaceship_moved
    end
  end
end
