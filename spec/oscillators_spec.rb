require 'spec_helper'

describe "GameOfLife (Oscillators)" do
  let(:blinker) {
    [[
      O*5,
      O*5,
      O+X*3+O,
      O*5,
      O*5
    ], 2]
  }

  let(:toad) {
    [[
      O*6,
      O*6,
      O*2+X*3+O,
      O+X*3+O*2,
      O*6,
      O*6
    ], 2]
  }

  let(:beacon) {
    [[
      O*6,
      O+X*2+O*3,
      O+X*2+O*3,
      O*3+X*2+O,
      O*3+X*2+O,
      O*6
    ], 2]
  }

  let(:pulsar) {
    [load_pattern('pulsar'), 3]
  }

  [:blinker, :toad, :beacon, :pulsar].each do |oscillator|
    it "#{oscillator} should oscillate" do
      oscillator, period = send(oscillator)
      game = GameOfLife.new(oscillator.dup)
      period.times { game.evolve }
      game.state.should == oscillator
    end
  end
end
