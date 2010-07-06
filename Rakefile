namespace :spec do
  desc "run specs across all implementations"
  task :run do
    Dir['./lib/game_of_life_*.rb'].each { |implementation|
      puts
      puts implementation.split('_').last
      puts `rspec -f progress -r #{implementation} spec`.lines.reject { |line| line.chomp.empty? }.join
    }
  end
end

namespace :bench do
  SIZE = 30
  EVOLUTIONS = 30

  def bench(file)
    implementation = File.basename(file,'.rb').split('_').last.capitalize
    implementation, time = `ruby -r ./#{file} bench.rb #{SIZE} #{EVOLUTIONS}`.lines.to_a
    [implementation.chomp, time.to_f]
  end

  desc "run single bench on default implementation in lib/game_of_life.rb"
  task :single do
    implementation, time = bench("lib/game_of_life.rb")
    message = `git log`.lines.take(5).last.strip
    puts result = "#{SIZE},#{EVOLUTIONS} #{"%.3f" % time} #{implementation.ljust(7)} #{message}"
    File.open('bench.log', 'a') { |fh| fh.puts(result) }
  end
  desc "run comparative bench on all implementations"
  task :compare do
    results = Dir['lib/game_of_life_*.rb'].map { |file|
      implementation, time = bench(file)
      "#{implementation}: #{"%.3f" % time}"
    }.sort_by { |s| s[-3..-1].to_i }.join(', ')

    puts results = "#{SIZE},#{EVOLUTIONS} [#{results}]"
    File.open('bench.log', 'a') { |fh| fh.puts(results) }
  end
end

task :default => ["spec:run"]
task :bench => ["bench:single", "bench:compare"]
