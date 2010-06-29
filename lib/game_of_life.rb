if RUBY_VERSION < "1.9.2"
  # Using a local copy of `backports` as Shoes can not access rubygems
  $: << File.expand_path("../backports-1.18.1/lib", __FILE__)
  require "backports"
end

require File.expand_path("../game_of_life_state", __FILE__)
