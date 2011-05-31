#!/usr/bin/env ruby
# main program without gui

require 'position'
require 'search'

class MyTeacher

  def initialize
    @p = Position.new
    @s = Search.new(@p)
    @p.printp
    puts
  end

  def run
    loop {
      total_moves = 0
      max_moves = 0
      min_moves = 1000
      @p.reset_to_starting_position
      #puts @p.num_pieces(Constants::WKING)
      #exit
      loop {
        can_move = @s.play
        break if not can_move

        nb_moves = @s.moves.size
        max_moves = nb_moves if nb_moves > max_moves
        min_moves = nb_moves if nb_moves < min_moves and nb_moves > 0
        total_moves += nb_moves
        moy = total_moves.to_f / @p.ply

        puts "#{@p.hply+1}. #{@s.played_move} (nb moves: #{nb_moves}, moy: #{moy}) hclock=#{@p.hclock}"
        @p.printp
        #sleep(0.1)
        gets
        #print @p.ply.to_s+ " "
        #STDOUT.flush
        break if @p.hply >= 300
        }
      puts
      puts "min: #{min_moves} max: #{max_moves}"
    }
  end

end

MyTeacher.new.run

