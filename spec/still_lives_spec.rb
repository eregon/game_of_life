require 'spec_helper'

describe "GameOfLife (Still lives)" do
  let(:block) {
    [
      O*4,
      [0,1,1,0],
      [0,1,1,0],
      O*4
    ]
  }

  let(:beehive) {
    [
      O*6,
      O*2+X*2+O*2,
      O+X+O*2+X+O,
      O*2+X*2+O*2,
      O*6
    ]
  }

  let(:loaf) {
    [
      O*6,
      O*2+X*2+O*2,
      O+X+O*2+X+O,
      O*2+X+O+X+O,
      O*3+X+O*2,
      O*6
    ]
  }

  let(:boat) {
    [
      O*5,
      O+X*2+O*2,
      O+X+O+X+O,
      O*2+X+O*2,
      O*5
    ]
  }

  [:block, :beehive, :loaf, :boat].each do |still_life|
    it "#{still_life} should stay alife" do
      still_life = send(still_life)
      game = GameOfLife.new(still_life.dup)
      game.evolve.should == still_life
      game.evolve.should == still_life
    end
  end
end
