require 'spec_helper'

describe "GameOfLife (Still lives)" do
  patterns("still_lives").each do |pattern|
    name = File.basename(pattern, File.extname(pattern))
    it "#{name} should stay alive" do
      game = GameOfLife.load_pattern(pattern).surround
      next_state = game.state
      game.evolve.should == next_state
      game.evolve.should == next_state
    end
  end
end
