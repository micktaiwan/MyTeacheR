#!/usr/bin/env ruby
# main program without gui

require 'position'
require 'search'

class MyTeacher

  def initialize
    @p = Position.new
    @s = Search.new(@p)
    @p.print_board
    puts
  end

  def run
    total_moves = 0
    iteration = 1
    max_moves = 0
    min_moves = 1000
    loop {
      can_move = @s.play
      nb_moves = @s.moves.size
      max_moves = nb_moves if nb_moves > max_moves
      min_moves = nb_moves if nb_moves < min_moves and nb_moves > 0
      total_moves += nb_moves
      moy = total_moves.to_f / iteration
      puts "#{@p.hply+1}. #{@s.played_move} (nb moves: #{nb_moves}, moy: #{moy})"
      @p.print_board
      #sleep(0.1)
      #gets
      break if not can_move
      iteration += 1
      }
  puts "min: #{min_moves} max: #{max_moves}"

  end

end

MyTeacher.new.run

