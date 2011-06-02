#!/usr/bin/env ruby
# main program without gui

require 'position'
require 'search'
#require 'utils'

class MyTeacher

  include MyTeacherUtils


  def initialize
    @p = Position.new
    @s = Search.new(@p)
    @p.printp
    puts
  end

  def run
    #puts case_to_index("c4")
    #puts Constants::WKNIGHT_TABLE[case_to_index("c4")]
    #exit
    loop {
      @p.reset_to_starting_position
      loop {
        puts "side: #{@p.side==WHITE ? "w":"b"}"
        can_move = @s.play
        break if not can_move

        @s.stats.print_end_turn_stats
        @s.stats.print_verbose_stats
        @p.printp
        #sleep(0.1)
        #gets
        #print @p.ply.to_s+ " "
        #STDOUT.flush
        break if @p.hply >= 300
        }
      puts
      puts "END"
    }
  end

end

MyTeacher.new.run

