require 'spec_helper'

describe "GameOfLife (Andrea Fazzi)" do
  let(:game) {
    GameOfLife.new [
      [0, 0, 0, 0],
      [0, 1, 0, 0],
      [0, 1, 0, 0],
      [0, 0, 1, 0],
      [0, 0, 0, 0]
    ]
  }

  it 'should return the cell at the given coordinates' do
    game[0, 1].should == 0
    game[1, 1].should == 1
  end

  it 'should clip the coordinates out of the game' do
    game[-1, 0].should == 0
    game[-3, 1].should == 1
    game[2, 8].should == 1
  end

  it 'should correctly evolve to the next generation' do
    a_0 = [
           [0, 0, 0, 0],
           [0, 1, 0, 0],
           [0, 1, 0, 0],
           [0, 0, 1, 0],
           [0, 0, 0, 0]
          ]
    a_1 = [
           [0, 0, 0, 0],
           [0, 0, 0, 0],
           [0, 1, 1, 0],
           [0, 0, 0, 0],
           [0, 0, 0, 0]
          ]
    a_2 = [
           [0, 0, 0, 0],
           [0, 0, 0, 0],
           [0, 0, 0, 0],
           [0, 0, 0, 0],
           [0, 0, 0, 0]
          ]
    b_0 = [
           [0, 0, 0, 0, 0, 0],
           [0, 0, 0, 0, 0, 0],
           [0, 1, 1, 1, 1, 0],
           [0, 0, 0, 0, 0, 0],
           [0, 0, 0, 0, 0, 0]
          ]
    b_1 = [
           [0, 0, 0, 0, 0, 0],
           [0, 0, 1, 1, 0, 0],
           [0, 0, 1, 1, 0, 0],
           [0, 0, 1, 1, 0, 0],
           [0, 0, 0, 0, 0, 0]
          ]
    b_2 = [
           [0, 0, 0, 0, 0, 0],
           [0, 0, 1, 1, 0, 0],
           [0, 1, 0, 0, 1, 0],
           [0, 0, 1, 1, 0, 0],
           [0, 0, 0, 0, 0, 0]
          ]
    c_0 = [
           [0, 0, 0, 0, 0, 0],
           [0, 0, 1, 0, 0, 0],
           [0, 0, 1, 1, 1, 0],
           [0, 0, 0, 0, 0, 0],
           [0, 0, 0, 0, 0, 0]
          ]
    c_1 = [
           [0, 0, 0, 0, 0, 0],
           [0, 0, 1, 0, 0, 0],
           [0, 0, 1, 1, 0, 0],
           [0, 0, 0, 1, 0, 0],
           [0, 0, 0, 0, 0, 0]
          ]
    c_2 = [
           [0, 0, 0, 0, 0, 0],
           [0, 0, 1, 1, 0, 0],
           [0, 0, 1, 1, 0, 0],
           [0, 0, 1, 1, 0, 0],
           [0, 0, 0, 0, 0, 0]
          ]
    c_3 = [
           [0, 0, 0, 0, 0, 0],
           [0, 0, 1, 1, 0, 0],
           [0, 1, 0, 0, 1, 0],
           [0, 0, 1, 1, 0, 0],
           [0, 0, 0, 0, 0, 0]
          ]
    GameOfLife.new(a_0).evolve.should == a_1

    game = GameOfLife.new(a_0)
    game.evolve.should == a_1
    game.evolve.should == a_2

    game = GameOfLife.new(b_0)
    game.evolve.should == b_1
    game.evolve.should == b_2

    game = GameOfLife.new(c_0)
    game.evolve.should == c_1
    game.evolve.should == c_2
    game.evolve.should == c_3
  end

  it 'should return a string' do
    game.to_s.should == "....\n.o..\n.o..\n..o.\n....".tr('o.', (Cell::ALIVE+Cell::DEAD rescue "# "))
    game.evolve
    game.to_s.should == "....\n....\n.oo.\n....\n....".tr('o.', (Cell::ALIVE+Cell::DEAD rescue "# "))
  end
end

