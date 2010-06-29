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
  fh.puts "#{SIZE},#{EVOLUTIONS} #{"%.3f" % time} #{commit} #{message}"
}

__END__
30,30 0.431 1b9591 Vendor backports
30,30 0.444 e73220 add a little benchmark util which log on itself the results
30,30 0.104 a53a1e add a Boolean-based GameOfLife
