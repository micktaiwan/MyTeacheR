#!/usr/bin/env ruby
# a performance test

require 'position'
require 'search'

class Perft

  def initialize
    @p = Position.new
    @s = Search.new(@p)
  end

  def run
    t = Time.now
    i = 0
    1000.times {
      break if not @s.play
      i += 1
      }
    total =  (Time.now - t)
    puts "#{i} moves in #{total} secs"
    puts "#{total/i} per move"
    @p.print_board
  end

end

Perft.new.run

