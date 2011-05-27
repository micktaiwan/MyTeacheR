#!/usr/bin/env ruby
# a performance test
# http://wismuth.com/chess/statistics-games.html

require 'position'
require 'search'

class Perft

  Pre_perft = {
  1=>20,
  2=>400,
  3=>8902,
  4=>197281,
  5=>4865609,
  6=>119060324,
  7=>3195901860,
  8=>84998978956,
  9=>2439530234167,
  10=>69352859712417
  }

  def initialize
    @p = Position.new
    @s = Search.new(@p)
  end

  def main
    depth = 3
    puts "depth is #{depth}. #{0.00224942242589507*Pre_perft[depth]/60} min to go"
    t = Time.now
    total = perft(Position.new, depth)
    s =  (Time.now - t)
    puts "#{total} moves in #{s} secs"
    puts "#{s/total} per move"
  end

  # return the number of move per ply
  def perft(p, depth=3, cur_depth=1)
    total = 0
    return 1 if depth == 0 # should never go there
    m = @p.gen_legal_moves # until perf(3) gen_moves is sufficient
    i = m.size
    return total+i if depth == 1
    puts "depth = #{depth}. #{i} moves" if cur_depth < 4

    m.each { |m|
      @p.make(m)
      total += perft(@p, depth-1, cur_depth+1)
      @p.unmake
      }
    #puts "#{@p.hply}: #{i}"
    total
  end

  def performance_run
    t = Time.now
    i = 0
    100.times {
      rv = @s.play
      break if not rv
      i += 1
      }
    total =  (Time.now - t)
    puts "#{i} moves in #{total} secs"
    puts "#{total/i} per move"
    @p.printp
  end

end

Perft.new.main

