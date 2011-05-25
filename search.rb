require 'position'
require 'eval'

class IllegalMoveException < RuntimeError
end


class Search

  include Constants

  attr_reader :played_move, :position, :moves

  def initialize(position)
    @position    = position
    @moves = []
  end

  def play
    @played_move = nil

    # type of play depends of the function used
    # random_move, simple
    m = depth_first

    return false if not m
    @position.make(m)
    @played_move = m
    true
  end

  def random_move
    @moves = @position.gen_legal_moves
    return nil if @moves.size == 0
    @moves[rand(moves.size)]
  end

  def depth_first
    score, move = search_root(-1000, 1000, 3, @position)
    puts "score: #{score}, best = #{move}"
    move
  end

  def search_root(a,b,depth,pos)
    return [] if(depth == 0)
    best = nil
    pos.gen_legal_moves.each do |m|
      pos.make(m)
      score = (pos.side==WHITE ? 1 : -1) * negamax(-b, -a, depth-1, pos)
      pos.unmake
      #return [score, m] if( score >= b )
      if( score > a )
        a     = score
        best  = m
      end
    end
    [a, best]
  end

  def negamax(a,b,depth, pos)
    return eval(pos) if(depth == 0)
    pos.gen_legal_moves.each do |m|
      pos.make(m)
      score = -negamax(-b, -a, depth-1, pos)
      pos.unmake
      return b if( score >= b )
      a = score if( score > a )
    end
    a
  end

end
=begin
http://chessprogramming.wikispaces.com/Search
Search Algorithms
The majority of chess-programs use some variation of the alpha-beta algorithm
to search the tree in depth-first manner, with big up to square-root savings for
the same search result as the pure minimax algorithm. Alpha-beta may be further
enhanced by PVS similar to Negascout and MTD(f). While move ordering in pure
minimax search don't cares - since all of branches and nodes are searched
anyway, it becomes crucial for the performance of alpha beta and enhancements.
Hans Berliner's chess-program HiTech and Ulf Lorenz's program P.ConNerS used
best-first approaches quite successfully.
=end

