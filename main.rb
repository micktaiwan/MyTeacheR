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
    loop {
      @s.play
      puts "#{@p.hply+1}. #{@s.played_move}"
      @p.print_board
      sleep(0.1)
      }
  end

end

MyTeacher.new.run

