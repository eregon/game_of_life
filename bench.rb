require "benchmark"

SIZE = 30
EVOLUTIONS = 30

if ARGV.delete("--compare") or ARGV.delete('-c')
  bench = <<EOS
  game = GameOfLife.new(#{SIZE})
  #{EVOLUTIONS}.times { game.evolve }
EOS
  results = Dir['lib/game_of_life_*.rb'].map { |file|
    implementation = File.basename(file,'.rb').split('_').last.capitalize
    contents = (IO.read(file) + bench)
    time = Benchmark.realtime {
      Dir.chdir('lib') do
        IO.popen('ruby', 'w') { |io| io.write(contents) }
      end
    } - 0.015 # Approximation of io time
    "#{implementation}: #{"%.3f" % time}"
  }.sort_by { |s| s[-3..-1].to_i }.join(', ')

  results = "#{SIZE},#{EVOLUTIONS} [#{results}]"
  puts results
  File.open(__FILE__, 'a') { |fh| fh.puts(results) }
else
  require File.expand_path('../lib/game_of_life', __FILE__)

  time = Benchmark.realtime {
    game = GameOfLife.new(SIZE)
    EVOLUTIONS.times { game.evolve }
  }

  File.open(__FILE__, 'a') { |fh|
    message = `git log`.lines.take(5).last.strip
    fh.puts(p "#{SIZE},#{EVOLUTIONS} #{"%.3f" % time} #{GameOfLife.implementation.to_s.ljust(7)} #{message}")
  }
end

__END__
30,30 0.431 Cell    Vendor backports
30,30 0.444 Cell    add a little benchmark util which log on itself the results
30,30 0.104 Boolean add a Boolean-based GameOfLife
30,30 0.088 Boolean optimize a bit by removing Boolean#alive? as it returns self
30,30 0.364 State   Add game_of_life_state and the Gosper_glider_gun
30,30 0.385 Cell    Add game_of_life_state and the Gosper_glider_gun
30,30 0.959 Fiber   Add game_of_life_fiber
30,30 0.438 Fiber   Optimize module.rb: class_eval("") is twice faster than define_method
30,30 0.122 Cell    Optimize module.rb: class_eval("") is twice faster than define_method
30,30 0.106 State   Optimize module.rb: class_eval("") is twice faster than define_method
30,30 0.090 Integer add game_of_life_integer, use attr_reader for @state
30,30 [Boolean: 0.089, Integer: 0.092, State: 0.107, Cell: 0.121, Fiber: 0.432]
30,30 0.069 Fast    add Fast implementation
30,30 [Fast: 0.072, Boolean: 0.091, Integer: 0.092, State: 0.109, Cell: 0.120, Fiber: 0.449]
30,30 0.053 Fast    Heavy refactoring of game_of_life_fast, and awesome speed improvement :)
30,30 [Fast: 0.056, Boolean: 0.090, Integer: 0.092, State: 0.111, Fiber: 0.439, Cell: 0.440]
30,30 0.017 C       add game_of_life_c, a C Ruby extension built for speed!
30,30 [C: 0.018, Fast: 0.054, Boolean: 0.090, Integer: 0.092, State: 0.108, Cell: 0.123, Fiber: 0.434]
30,30 0.013 C       improve game_of_life_c: create a temporary int[] from VALUE[] because it is 9*n accessed.
30,30 [C: 0.015, Fast: 0.055, Boolean: 0.092, Integer: 0.096, State: 0.106, Cell: 0.120, Fiber: 0.448]
30,30 0.003 C       improve gol_neighbors by computing only once the neighbors_delta
30,30 [C: 0.004, Fast: 0.057, Boolean: 0.090, Integer: 0.092, State: 0.108, Cell: 0.183, Fiber: 0.440]
30,30 0.002 C       improve gol_state by using rb_ary_subseq
30,30 [C: 0.003, Fast: 0.056, Boolean: 0.092, Integer: 0.093, State: 0.108, Cell: 0.124, Fiber: 0.438]
30,30 0.002 C       Fix the problem of 1-dimensional Arrays with neighbors
30,30 [C: 0.003, Fast: 0.070, Boolean: 0.089, Integer: 0.092, State: 0.110, Cell: 0.122, Fiber: 0.432]
