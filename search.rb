require 'position'
require 'eval'
require 'stats'

class IllegalMoveException < RuntimeError
end

class Search

  include Constants

  attr_reader :played_move, :position, :done, :stats
  attr_accessor :debug

  def initialize(position)
    @p      = position
    @stats  = Stats.new(@p, self)
    @debug = nil
  end

  def play(type=:depth_first)
    @done = nil
    @played_move = nil
    @stats.start_turn

    # type of play depends of the function used
    # random_move, simple
    move, score = case type
      when :iterative_search
        iterative_start
      when :depth_first
        depth_first
      when :random
        random_move
      else
        raise "unknown type of play '#{type.to_s}'"
      end
    @stats.end_turn(score, move)
    return false if not move
    @p.make(move)
    @played_move = move
    @done = true
    true
  end

  def random_move
    @nodes = @p.gen_legal_moves
    return nil if @nodes.size == 0
    @nodes[rand(@nodes.size)]
  end

  def depth_first
    search_root(-100000, 100000, 3)
  end

  def iterative_start
    @moves = [] # store PV
    do_iterate(0, 1)
    #puts @moves[0].size
    puts @moves[0].class
    @moves[0] # return best move
  end

  def do_iterate(depth, max_depth)
    return if depth == max_depth
    @moves[depth] = Array.new if not @moves[depth]
    current_level = @moves[depth]
    current_level = iterative_search(-100000, 100000)

    current_level.each_with_index { |m,index|
      @p.make(m[0])
      current_level[index] = iterative_search(-100000, 100000)
      #puts "#{current_level}, #{current_level[index].size}"
      @p.unmake
      }
    do_iterate(depth+1, max_depth)
  end

  def iterative_search(a,b)
    moves = @p.gen_legal_moves.map do |m|
      @stats.inc_turn_nodes
      @p.make(m)
      score = quiesce(a,b,0)
      @p.unmake
      [m,score]
    end
    moves.sort_by { |m| m[1] }
  end

  def search_root(a,b,depth)
    return [0,nil] if(depth == 0)
    best = nil
    @p.gen_legal_moves.each do |m|
      @stats.inc_turn_nodes
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
        puts "best so far: #{m}, score: #{a}, nodes: #{@stats.current_turn_nodes}, n per s: #{@stats.nodes_per_second})" if @debug
      end
    end
    [best, a]
  end

  def factor
    (@p.side==WHITE ? 1 : -1)
  end

  def negamax(a,b,depth)
    return quiesce(a,b,0) if(depth == 0)
    #return factor*evaluate() if(depth == 0)
    moves = @p.gen_legal_moves
    return factor*99999 if moves.size == 0
    moves.each do |m|
      @stats.inc_turn_nodes
      @p.make(m)
      score = -negamax(-b, -a, depth-1)
      @p.unmake
      return b if( score >= b )
      a = score if( score > a )
    end
    a
  end

  def quiesce(alpha, beta, depth)
    stand_pat = factor*evaluate()
    return beta if( stand_pat >= beta )

    #BIG_DELTA = piece_value(QUEEN)
    #if ( isPromotingPawn() ) BIG_DELTA += 775;

    return alpha if(stand_pat < alpha - BIG_DELTA) # delta pruning

    alpha = stand_pat if(stand_pat > alpha)
    return alpha if depth >= 3 # FIXME

    moves = @p.gen_legal_captures
    #puts "d=#{depth}, captures: #{moves.size}, current score=#{alpha}"

    #moves = moves.map { |m| [m,see_root(m)] }
    #moves = moves.select { |m| m[1] > 0 }
    #moves = moves.sort_by { |m| -m[1] }
    #moves = moves.map { |m| m[0] }

    moves.each do |m|
      @p.make(m)
      score = -quiesce( -beta, -alpha, depth+1 )
      @p.unmake

      return beta if( score >= beta )
      alpha = score if( score > alpha )
    end
    alpha
  end

  # Static Exchange Evaluation from a Move
  def see_root(capture_move)
    @p.make(capture_move)
    value = piece_value(capture_move.piece) - see(capture_move.to)
    @p.unmake
    return value
  end

  # generic Static Exchange Evaluation
  def see(square)
    piece, from_square = @p.get_smallest_attacker(square, @p.side)
    return 0 if not piece
    move = Move.new(piece, from_square, square, @p.piece_at(square))
    @p.make(move)
    value = piece_value(piece) - see(square)
    @p.unmake
    return value
  end

end

