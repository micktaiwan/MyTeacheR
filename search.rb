require 'position'
require 'eval'

class IllegalMoveException < RuntimeError
end


class Search

  include Constants

  attr_reader :played_move, :position, :moves, :done

  def initialize(position)
    @p    = position
    @moves = []
  end

  def play(type=:depth_first)
    @done = nil
    @played_move = nil
    @nodes = 0
    @start_time = Time.now

    # type of play depends of the function used
    # random_move, simple
    m = case type
      when :depth_first
        depth_first
      when :random
        random_move
      else
        raise "unknown type of play '#{type.to_s}'"
      end

    return false if not m
    @p.make(m)
    @played_move = m
    @done = true
    true
  end

  def random_move
    @moves = @p.gen_legal_moves
    return nil if @moves.size == 0
    @moves[rand(moves.size)]
  end

  def depth_first
    t = Time.now
    score, move = search_root(-1000, 1000, 3)
    puts "## end score: #{score.to_f/100}, best = #{move}, t = #{Time.now-t}, nodes: #{@nodes}, #{@nodes.to_f/(Time.now-@start_time)}"
    move
  end

  def search_root(a,b,depth)
    return [0,nil] if(depth == 0)
    best = nil
    puts "side: #{@p.side==WHITE ? "w":"b"}"
    @p.gen_legal_moves.each do |m| # FIXME: gen_legal_moves
      @nodes += 1
      @p.make(m)
      score = -negamax(-b, -a, depth-1)
      #puts "move: #{m}"
      #puts "score: #{score}"
      #@p.printp
      @p.unmake
      #return [score, m] if( score >= b )
      if( score > a )
        a     = score
        best  = m
        puts "best so far: #{m}, score: #{a}, nodes: #{@nodes}, #{@nodes.to_f/(Time.now-@start_time)})"
      end
    end
    [a, best]
  end

  def negamax(a,b,depth)
    return (@p.side==WHITE ? 1 : -1)*evaluate() if(depth == 0)
    #puts "d=#{depth}"
    @p.gen_legal_moves.each do |m| # FIXME: gen_legal_moves
      @nodes += 1
      @p.make(m)
      score = -negamax(-b, -a, depth-1)
      @p.unmake
      return b if( score >= b )
      if( score > a )
        a = score
        #puts "d=#{depth}: s=#{score}, b=#{b}"
      end
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

