require 'spec_helper'

describe "GameOfLife (Oscillators)" do
  let(:periods) {
    { :blinker => 2, :toad => 2, :beacon => 2, :pulsar => 3 }
  }
  patterns("oscillators").each do |pattern|
    name = File.basename(pattern, File.extname(pattern))
    it "#{name} should oscillate" do
      game = GameOfLife.load_pattern(pattern).surround(2)
      initial_state = game.state
      periods[name.to_sym].times { game.evolve }
      game.state.should == initial_state
    end
  end
end
