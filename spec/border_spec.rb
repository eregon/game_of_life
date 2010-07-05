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
      cycle = (advance.last > advance.first ? spaceship.size : spaceship.first.size) *
              period / advance.max
      cycle.times { game.evolve }
      game.state.should == spaceship
    end
  end

  # Theoric spec
  # [ , , ]
  # [ ,p, ]
  # [ , , ]
  # The original pos1d failed because if we do -1 and we are on the column 0, we go one row upper than expected.
  # The solution is to check for this case, and then as 8/9 neighbors are correct, make the last one good
  # The symmetrical problem is identic of course
  it "should round-trip for coordinates" do
    w, h = 6, 5
    s = w*h
    neighbors1d = [1, 1-w, -w, -1-w, -1, w-1, w, w+1]
    neighbors2d = [[1,0], [1,-1], [0,-1], [-1,-1], [-1,0], [-1,1], [0,1], [1,1]]
    ary1d = Array.new(s) { |i| i }
    ary2d = Array.new(h) { |i| Array.new(w) { |j| i*w+j } }
    ary1d.should == ary2d.reduce(:+)
    pos1d = lambda { |pos, delta| (pos+delta) % s } # original, not working
    pos1d = lambda { |pos, delta|
      try = pos+delta
      if pos % w == 0 and delta == -w-1
        try += 3*w
      elsif pos % w == w-1 and delta == w+1
        try -= 3*w
      end
      try % s
    }
    s.times { |pos|
      y, x = pos / w, pos % w
      n1, n2 = neighbors1d.each_with_index.with_object([[],[]]) { |(delta, i), (n1, n2)|
        dx, dy = neighbors2d[i]
        n1 << ary1d[pos1d[pos,delta]]
        n2 << ary2d[(y+dy) % h][(x+dx) % w]
      }.map(&:sort)
      n1.should == n2
    }
  end
end
