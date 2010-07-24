require 'spec_helper'

describe "GameOfLife (#initialize)" do
  let(:ary) {
    [
      [1,0,1,0],
      [1,0,0,1],
      [0,1,0,0]
    ]
  }

  it "should initialize with an Array" do
    GameOfLife.new(ary).state.should == ary
  end

  it "should initialize with a pattern" do
    GameOfLife.load_pattern("still_lifes/boat").state.should == [[1,1,0],[1,0,1],[0,1,0]]
  end

  it "should initialize with an Integer (width)" do
    width = 3+rand(3)
    state = GameOfLife.new(width).state
    state.size.should == width
    state.all? { |row| row.size.should == width }
  end

  it "should initialize with 2  Integer (width,height)" do
    width = 3+rand(3)
    height = width+1
    state = GameOfLife.new(width,height).state
    state.size.should == height
    state.all? { |row| row.size.should == width }
  end
end
