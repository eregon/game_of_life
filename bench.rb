require "benchmark"

SIZE, EVOLUTIONS = ARGV.map(&:to_i)

raise "Invalid size: #{SIZE}" if SIZE <= 0

puts GameOfLife.implementation

puts Benchmark.realtime {
  game = GameOfLife.new(SIZE)
  EVOLUTIONS.times { game.evolve }
}
