#!/usr/bin/env ruby
# main program without gui

require 'position'

class MyTeacher

  def initialize
    @p = Position.new
  end

  def run
    loop {
      @p.play
      puts "Computer played #{@p.played_move}"
      break
      }
  end

end

MyTeacher.new.run

