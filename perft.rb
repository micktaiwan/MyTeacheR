#!/usr/bin/env ruby
# a performance test
# http://wismuth.com/chess/statistics-games.html

require 'position'
require 'search'

class Perft

  include MyTeacherUtils

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

# history of s/n
# 1.  0.00224942242589507
# 2.  0.00118620580087328

  def main
    depth = 4
    pt = pretty_time(0.0012*Pre_perft[depth])
    puts "depth is #{depth}\n#{pt} to go"
    t = Time.now
    total = perft(Position.new, depth)
    s =  (Time.now - t)
    puts "#{total} moves in #{pretty_time(s)}"
    puts "#{s/total} second per move"
    result = total == Pre_perft[depth]
    puts result ? "Good result !" : "BAD result ! should have been #{Pre_perft[depth]} " #196981
    exit (result ? 0 : 1)
  end

  # return the number of move per ply
  def perft(p, depth=3, cur_depth=1)
    total = 0
    return 1 if depth == 0 # should never go there
    m = @p.gen_legal_moves # until perf(3) gen_moves is sufficient
    i = m.size
    return total+i if depth == 1
    #puts "depth = #{depth}. #{i} moves" if cur_depth < 4

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
    10.times {
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


