#!/usr/bin/env ruby
# main program without gui

require 'position'
require 'search'
#require 'utils'

class MyTeacher

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

  def main
    loop {
      print ">"
      input = gets.strip
      case
      when (input=="" or input=="play")
        puts "side: #{@p.side==WHITE ? "w":"b"}"
        start = Time.now
        can_move = @s.play
        puts "move: #{@s.move}, score = #{@s.score}, #{pretty_time(Time.now()-start)}"
        @p.printp
        puts "#{@p.side==WHITE ? "Blacks":"Whites"} win !" if !can_move
      when input=="reset"
        @p.reset_to_starting_position
      when input=="unmake"
        @p.unmake
        @p.printp
      when input[0..4]=="perft"
        do_perft(input[6..-1].to_i)
      when input=="show"
        @p.printp
      when input=="moves"
        puts @p.gen_legal_moves.join(",")
      when input=="solo"
        solo
      when input[0..3]=="test"
        do_testsuite(input[5..-1].to_i)
      when input[0..5]=="divide"
        divide(input[7..-1].to_i)
      when input[0..7]=="load fen"
        @p.load_fen input[9..-1]
        @p.printp
      else # move
			  input.gsub!(/\?/, '')
			  begin
				  @p.make_from_input(input)
				  @p.printp
			  #rescue IllegalMoveException
				#  logout "Illegal move: #{input}"
			  rescue	Exception=> e
				  puts e
			  end
      end
      }
  end

  def do_perft(depth)
    pt = pretty_time(0.0012*Pre_perft[depth])
    puts "depth is #{depth}. #{pt} to go"
    t = Time.now
    total = perft(depth)
    s =  (Time.now - t)
    puts "#{total} moves in #{pretty_time(s)}"
    puts "#{s/total} second per move"
    result = total == Pre_perft[depth]
    puts result ? "Good result !" : "BAD result ! should have been #{Pre_perft[depth]} "
    total
  end

  # return the number of move per ply
  def perft(depth=3, cur_depth=1)
    return 1 if depth == 0
    m = @p.gen_legal_moves # until perft(3) gen_moves is sufficient
    return m.size if depth == 1
    total = 0
    m.each { |m|
      @p.make(m)
      total += perft(depth-1, cur_depth+1)
      @p.unmake
      }
    total
  end

  def divide(depth)
    @p.gen_legal_moves.sort_by {|m| m.to_s} .each { |m|
      print m, "  "
      @p.make(m)
      puts perft(depth-1)
      @p.unmake
      }
  end

  def do_testsuite(depth)
    depth = 3 if depth==""
    f = File.open("perftsuite.epd")
    begin
      loop do
        line = f.readline
        break unless line
        arr = line.split(";")
        print '.'
        STDOUT.flush
        @p.load_fen arr[0]
        d = arr[depth].split(" ")
        result = perft(depth)
        if result != d[1].to_i
          puts
          puts arr[0]
          puts "BAD: #{result} != #{d[1]}"
        end
      end
	  rescue	Exception=> e
		  puts e
    ensure
      f.close unless f.nil?
    end
  end


  def solo
    loop {
      @p.reset_to_starting_position
      loop {
        puts "side: #{@p.side==WHITE ? "w":"b"}"
        can_move = @s.play
        break if not can_move
        @s.stats.print_end_turn_stats
        @s.stats.print_verbose_stats
        @p.printp
        break if @p.hply >= 300
        }
      puts
      puts "END"
    }
  end

end

MyTeacher.new.main


