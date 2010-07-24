require 'game_of_life'

O, X = [0], [1]

#def load_pattern(name)
#  IO.read("patterns/#{name}.txt").lines.map { |line| line.chomp.tr('xXO .', '11100').chars.map(&:to_i) }
#end

def patterns(dir)
  Dir[File.expand_path("../../patterns/#{dir}/*", __FILE__)]
end

def show(ary)
  puts "--begin"
  puts ary.to_s.lines.map { |l| l.chomp+"|\n" }
  puts "--end"
end
