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
    return false if not m
    @position.make(m)
    @played_move = m
    true
  end

  def rand_move
    moves = @position.gen_moves
    return nil if moves.size == 0
    moves[rand(moves.size)]
  end

end

