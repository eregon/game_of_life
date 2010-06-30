# Rules
#   each cell 2 possible states, life of death
#   8 neighbours
#    - any life cell < 2 neighbours dies
#    - any life cell > 3 neighbours dies
#    - any live cell with 2 or 3 neighbours lives to next generation
#    - any dead cell with exactly 3 live neighbours becomes a live cell
# first generation: apply pattern
#

### EXAMPLE ##########################################################################################################
# WRITE YOUR OWN TESTS, OF COURSE
# test-driven development is the best, this is just to show you how it should work (if it's not clear from rules)
# Plus varying parameters on initialization allows you to do cooler things, like play with different sizes, seeds, etc.
#######################################################################################################################

require 'spec_helper'

describe "GameOfLife (Basic)" do
  let(:game) {
    GameOfLife.new(3)
  }

  it "should kill with no neighbours" do
    game.state = [[1,0,0],[0,0,0],[0,0,0]]
    game.evolve[0][0].should == 0
  end

  it "should kill with just one neighbour" do
    game.state = [[0,0,0],[1,0,0],[1,0,0]]
    game.evolve
    game.state[1][0].should == 0
    game.state[2][0].should == 0
  end

  it "should kill with more than 3 neighbours" do
    game.state = [[1,1,1],[1,1,1],[1,1,1]]
    game.evolve
    game.state.should == [[0,0,0],[0,0,0],[0,0,0]]
  end

  it "should give birth if 3 neighbours" do
    game.state = [[1,0,0],[1,1,0],[0,0,0]]
    game.evolve
    game.state.should == [[1,1,1],[1,1,1],[1,1,1]]
  end
end
