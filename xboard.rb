#!/usr/bin/env ruby
require 'position'
require 'search'

confirm       = false
$stdout.sync  = true
$stderr.sync  = true
Thread.abort_on_exception = true

def time_it label
  yield
end

def logout msg
  $stderr.print "Out:#{msg}\n"
  print "#{msg}\n"
end

module Enumerable
  def rand
    self[Kernel.rand(self.size)]
  end
end

def play p, s
  Thread.new { s.play }
  until s.done; sleep(0.2); end
  move = s.move
  if not move
    puts "RESULT 1-0 {White Mates}"
  end
  logout "move #{move.to_s(:xboard)}"
  move
end

st = Stats.new
p  = Position.new(st)
s  = Search.new(p,st)
$stdin.each do |move|
  move.strip!
  $stderr.print "In :#{move}\n"
  case move
    when "xboard" then
      logout ""
      logout "tellics set f5 1=1"
    when "confirm_moves"
      confirm = true
      logout "Will now confirm moves."
    when /.{0,1}new/
      p.reset_to_starting_position
      logout "tellics set 1 MyTeacher"
    when /^protover/ then
      logout "feature sigint=0 sigterm=0 ping=1 done=1"
    when /^ping\s+(.*)/ then
      logout "pong #{$1}"
    when "quit"
      exit
    when /^st/ then
    when /^level/ then
    when /^time/ then
    when /^otim/ then
    when "hard" then
    when "random" then
    when /^accepted/ then
      # ignore
    else
      move.gsub!(/\?/, '')
      begin
        p.make_from_input(move)
        logout "Legal move: #{move}" if confirm
        play(p,s)
      rescue IllegalMoveException
        logout "Illegal move: #{move}"
      rescue  Exception=> e
        puts e
      end
  end
end


