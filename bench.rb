require "benchmark"

SIZE, EVOLUTIONS = ARGV.map(&:to_i)

puts GameOfLife.implementation

puts Benchmark.realtime {
  game = GameOfLife.new(SIZE)
  EVOLUTIONS.times { game.evolve }
}
