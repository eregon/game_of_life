namespace "spec" do
  desc "run specs across all implementations"
  task :run do
    Dir['./lib/game_of_life_*.rb'].each { |implementation|
      puts
      puts implementation.split('_').last
      puts `rspec -f progress -r #{implementation} spec`.lines.reject { |line| line.chomp.empty? }.join
    }
  end
end

namespace "bench" do
  desc "run single bench on default implementation in lib/game_of_life.rb"
  task :single do
    ruby "bench.rb"
  end
  desc "run comparative bench on all implementations"
  task :compare do
    ruby "bench.rb --compare"
  end
end
