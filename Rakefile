begin
  require "term/ansicolor"
  include Term::ANSIColor
rescue
  def green s
    "\e[32m#{s}\e[0m"
  end
  def red s
    "\e[31m#{s}\e[0m"
  end
end

desc "run specs across all implementations"
task :spec do
  Dir['./lib/game_of_life_*.rb'].each { |implementation|
    print implementation.split('_').last + ": "
    # puts `rspec -f progress -r #{implementation} spec`.lines.reject { |line| line.chomp.empty? }.join
    cmd = "rspec -f progress -r #{implementation} spec"
    cmd << " &> /dev/null"
    puts system(cmd) ? green("PASS") : red("FAIL")
  }
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features) do |t|
  opts = "features --format progress"
end

desc "run Cucumber across all implementations"
task :cucumber do
  Dir['./lib/game_of_life_*.rb'].each { |implementation|
    print implementation.split('_').last + ": "
    cmd = ["cucumber"]
    cmd << "-r #{implementation} -r lib/game_of_life.rb"
    cmd << "-r features/step_definitions/game_of_life_steps.rb"
    cmd << "--format progress --quiet"
    cmd << "features"
    cmd << "&> /dev/null"
    puts system(cmd.join(' ')) ? green("PASS") : red("FAIL")
  }
end

namespace :bench do
  SIZE = 30
  EVOLUTIONS = 30
  require "timeout"

  def bench(file)
    begin
      implementation, time = Timeout.timeout(1) {
        `ruby -r ./#{file} bench.rb #{SIZE} #{EVOLUTIONS}`.lines.to_a
      }
      [implementation.chomp, time.to_f]
    rescue Timeout::Error
      sleep 0.5
      [nil, nil]
    end
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
      "#{implementation}: #{"%.3f" % time}" if time
    }.compact.sort_by { |s| s[-3..-1].to_i }.join(', ')

    puts results = "#{SIZE},#{EVOLUTIONS} [#{results}]"
    File.open('bench.log', 'a') { |fh| fh.puts(results) }
  end
end

task :default => [:spec]
task :bench => ["bench:single", "bench:compare"]
