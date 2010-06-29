require "benchmark"
require File.expand_path('../lib/game_of_life', __FILE__)

SIZE = 30
EVOLUTIONS = 30
time = Benchmark.realtime {
  game = GameOfLife.new(SIZE)
  EVOLUTIONS.times { game.evolve }
}

File.open(__FILE__, 'a') { |fh|
  log = `git log`.lines.to_a
  commit, message = log[0].split.last[0...6], log[4].strip
  fh.puts(p "#{SIZE},#{EVOLUTIONS} #{"%.3f" % time} #{commit} #{GameOfLife.implementation.to_s.ljust(7)} #{message}")
}

__END__
30,30 0.431 1b9591 Cell    Vendor backports
30,30 0.444 e73220 Cell    add a little benchmark util which log on itself the results
30,30 0.104 a53a1e Boolean add a Boolean-based GameOfLife
30,30 0.088 1543ea Boolean optimize a bit by removing Boolean#alive? as it returns self
30,30 0.364 ffde80 State   Add game_of_life_state and the Gosper_glider_gun
30,30 0.385 ffde80 Cell    Add game_of_life_state and the Gosper_glider_gun
30,30 0.959 b482a8 Fiber   Add game_of_life_fiber
