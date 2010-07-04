require 'spec_helper'

describe "GameOfLife (Border)" do
  let(:glider) {
    [load_pattern('glider'), 4, [1, 1]]
  }

  let(:lightweight_spaceship) {
    [load_pattern('lightweight_spaceship'), 4, [2, 0]]
  }

  [:glider, :lightweight_spaceship].each do |spaceship|
    it "#{spaceship} should be at the same place after a cycle" do
      spaceship, period, advance = send(spaceship)
      game = GameOfLife.new(spaceship.dup)
      original_state = game.to_s
      cycle = (advance.last > advance.first ? spaceship.size : spaceship.first.size) *
              period / advance.max
      cycle.times { game.evolve }
      new_state = game.to_s
      if new_state == original_state
        game.state.should == spaceship
      else
        # puts :original_state
        # puts original_state
        # puts :new_state
        # puts new_state
      end
    end
  end
end
