require 'game_of_life'

O, X = [0], [1]

def load_pattern(name)
  IO.read("patterns/#{name}.txt").lines.map { |line| line.chomp.tr('xX ', '110').chars.map(&:to_i) }
end
