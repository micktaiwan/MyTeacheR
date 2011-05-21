require 'position'

class IllegalMoveException < RuntimeError
end


class Search

  include Constants

  attr_reader :played_move, :position

  def initialize(position)
    @position    = position
    @played_move = nil
  end

  def play
    m = rand_move
    @position.make(m)
    @played_move = m
    true
  end

  def rand_move
    moves = @position.gen_moves
    raise "no more move possible" if moves.size == 0
    moves[rand(moves.size)]
  end

end

