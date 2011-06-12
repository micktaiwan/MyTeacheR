#!/usr/bin/env ruby
# main program without gui

require 'position'
require 'search'
require 'readline'

class MyTeacher

  ProgramVersion = "MyTeacheR - v0.1 - 12 June 2011"
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

  CLIST = [
    'play', 'unmake', 'show', 'help',
    'reset', 'load fen ', 'solo', 'quit', 'exit',
    'best on', 'best off', 'moves',
    'perft ', 'divide ', 'test ', 'ptest', 'xboard'
    ].sort

  def initialize
    puts "Welcome to #{ProgramVersion} !\nType 'help' to get... help.\nPress TAB for autocompletion."
    @stats    = Stats.new
    @p        = Position.new(@stats)
    @s        = Search.new(@p, @stats)
    @s.debug  = true
  end

  # TODO: a command to launch xboard
  def print_help
    puts
    puts "********* PLAY"
    puts "e2e4..............play a move"
    puts "play/[Enter]......forces computer to play this position"
    puts "unmake............back up one move"
    puts "show..............print the board"
    puts "xboard............launch a graphical interface (if xboard is installed)"
    puts
    puts "********* UTILS"
    puts "quit/exit.........exit program"
    puts "reset.............reset the board to initial position"
    puts "load fen <fen>....load a FEN position"
    puts "solo..............start an infinite loop, computer playing alternatively from current position. Ctrl-C to stop"
    puts "best on...........display best move while searching (default)"
    puts "best off..........do not display best move while searching"
    puts
    puts "********* DEBUG AND TEST"
    puts "moves.............print all possible next moves for this position"
    puts "perft <n>.........display Perft(n)"
    puts "divide <n>........display Divide(n)"
    puts "test <n>..........generate all possible moves for a suite of positions at depth n"
    puts "ptest.............performance test suite"
    puts
  end

  def main
    comp = proc { |s| CLIST.grep( /^#{Regexp.escape(s)}/ ) }
    Readline.completion_append_character = ""
    Readline.completion_proc = comp
    begin
      while input = Readline.readline('>', true)
        begin
          @dump = @p.dump # in case of fired Exception
          case
          when (input=="quit" or input=="exit")
            exit
          when input=="help"
            print_help
          when (input=="" or input=="play")
            puts "side: #{@p.side==WHITE ? "w":"b"}"
            start = Time.now
            can_move = @s.play
            puts "move: #{@s.move}, score = #{@s.score}, #{pretty_time(Time.now()-start)}"
            @p.printp
            puts "#{@p.side==WHITE ? "Blacks":"Whites"} win !" if !can_move
          when input=="reset"
            @p.reset_to_starting_position
            @p.printp
          when input=="unmake"
            @p.unmake
            @p.printp
          when input[0..4]=="perft"
            do_perft(input[6..-1].to_i)
          when input[0..3]=="best"
            if input[5..6] == "on"
              @s.debug = true
              puts "Best move display is now on"
            else
              @s.debug = nil
              puts "Best move display is now off"
            end
          when input=="show"
            @p.printp
          when input=="moves"
            @p.gen_legal_moves.sort_by {|m| m.to_s}.each do |m|
              puts "#{m.to_s}: #{m.inspect}"
            end
          when input=="solo"
            solo
          when input[0..5]=="divide"
            divide(input[7..-1].to_i)
          when input[0..7]=="load fen"
            @p.load_fen input[9..-1]
            @p.printp
          when input[0..3]=="test"
            do_testsuite(input[5..-1].to_i)
          when input=="ptest"
            do_performancetestsuite
          when input=="xboard"
            `xboard -fcp "./xboard.rb" -debug -size Medium`
          else # move
            input.gsub!(/\?/, '')
            begin
              puts "test"
              @p.make_from_input(input)
              @p.change_side if color(@p.history.last[0].piece) == @p.side # this test allow to move the same color 2 times (not real chess!)
              @p.printp
            rescue IllegalInput
              puts "Illegal input: #{input}"
            rescue IllegalMoveException
              puts "Illegal move: #{input}"
            rescue    Exception=> e
              puts e
              puts e.backtrace
              @p.load(@dump)
            end
          end
        # inner loop
        rescue  Exception=> e
          puts e
          puts e.backtrace
          @p.load(@dump)
        end
      end
    # outer loop
    rescue  Interrupt=> e # Ctrl-C
      puts
    rescue  Exception=> e
      puts e
      puts e.backtrace
    end
  end

# history of s/n
# 1.  0.00224942242589507
# 2.  0.00118620580087328  with bitscan and knight bitboards
# 3.  0.00110999253349284  with king bitboards
# 4.  0.00105323814873062  with rook moves (and queens using rooks moves)
# 5   0.000979309031678275 without Proc.new and tweaking colored_piece

  def do_perft(depth) # http://wismuth.com/chess/statistics-games.html
    pt = pretty_time(0.000985*Pre_perft[depth])
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
    @p.gen_legal_moves.sort_by {|m| m.to_s}.each { |m|
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
        break if f.eof
        line = f.readline
        break unless line != ""
        next if line[0].chr == '#'
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
    rescue Exception=> e
      puts e
      puts e.backtrace
    ensure
      f.close unless f.nil?
    end
    puts
  end

  def do_performancetestsuite
    puts "Starting strength test suite. Ctrl-C to stop it."
    f = File.open("wac.epd")
    bad  = []
    good = []
    total = 0
    time  = 0
    begin
      loop do
        break if f.eof
        line = f.readline
        next unless line != ""
        next if line[0].chr == '#'
        arr = line.split(";")
        #print '.'
        #STDOUT.flush
        arr2 = arr[0].split(" bm ")
        raise "oops " if arr2.size < 2
        fen   = arr2[0]
        @p.load_fen fen
        puts
        puts "==== Problem ##{total+1}: #{fen} ===="
        puts "#{@p.side == WHITE ? "Whites":"Blacks"} to move"
        @p.printp
        best_moves  = arr2[1].split(" ").map { |m| @p.algebraic_read(m)}
        puts "Best moves are #{best_moves.join(" ")}. Now searching for them..."

        start = Time.now
        @s.play
        time = Time.now-start
        total += 1
        puts "My move is #{@s.move}"
        solution_found = nil
        for move in best_moves
          if move.to_s == @s.move.to_s
            puts "Good result :)"
            good << [fen, arr2[1], @s.move.to_s, time]
            solution_found = true
            break
          end
        end
        if !solution_found
          puts "BAD result :("
          bad << [fen, arr2[1], @s.move.to_s, time]
        end
        puts "time: #{pretty_time(time)}"
        puts "On #{total} problems, #{bad.size} (#{round(bad.size*100/total)}%) were not found. Total time: #{pretty_time(bad.inject(0){|sum,i| sum+i[3]} + good.inject(0){|sum,i| sum+i[3]})}"
      end
    rescue      Interrupt=> e # Ctrl-C
      puts
      puts "On #{total} problems, #{bad.size} (#{round(bad.size*100/total)}%) were not found. Total time: #{pretty_time(bad.inject(0){|sum,i| sum+i[3]} + good.inject(0){|sum,i| sum+i[3]})}"
    rescue Exception=> e
      puts e
      puts e.backtrace
    ensure
      f.close unless f.nil?
    end
    for b in bad
      puts "#{b[0]} #{b[1]} but played #{b[2]}"
    end
  end

  def solo
    begin
      loop do
        #@p.reset_to_starting_position
        loop {
          @dump = @p.dump
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
      end
    rescue      Interrupt=> e # Ctrl-C
      puts
    rescue        Exception=> e
      puts e
      puts e.backtrace
    ensure
      @p.load(@dump)
    end
  end

end

MyTeacher.new.main
